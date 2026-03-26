#!/usr/bin/env bash
set -euo pipefail

# ── Paths ──────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
TEMPLATE="$PLUGIN_ROOT/skills/showcase-generator/references/showcase-template.html"

# ── Find config ────────────────────────────────────────────────
CONFIG=""
for loc in "./.idea-lab.config.md" "$HOME/.claude/.idea-lab.config.md" "$HOME/idea-lab/.idea-lab.config.md"; do
  [[ -f "$loc" ]] && CONFIG="$loc" && break
done
if [[ -z "$CONFIG" ]]; then
  echo "Error: No .idea-lab.config.md found" >&2
  exit 1
fi

# ── Parse config frontmatter ──────────────────────────────────
get_config() {
  awk -v key="$1" '
    /^---$/ { if (fm) exit; fm=1; next }
    fm && index($0, key ":") == 1 {
      sub(/^[^:]+:[[:space:]]*/, "")
      print
      exit
    }
  ' "$CONFIG"
}

IDEAS_PATH="$(get_config ideas_path)"
DEMOS_DIR="$(get_config demos_dir)"
SHOWCASE_PATH="$(get_config showcase_path)"
IDEA_FILTER="$(get_config idea_filter)"
IDEA_FOLDERS="$(get_config idea_folders)"
SHOWCASE_DIR="$(dirname "$SHOWCASE_PATH")"
IDEAS_JSON="$SHOWCASE_DIR/ideas.json"

mkdir -p "$SHOWCASE_DIR" "$DEMOS_DIR"

# ── Pre-compute demo file list ─────────────────────────────────
# One find call instead of 78. Store basenames in a newline-separated string.
DEMO_FILES=""
if [[ -d "$DEMOS_DIR" ]]; then
  DEMO_FILES="$(find "$DEMOS_DIR" -maxdepth 1 -name "*.html" -type f -exec basename {} \; 2>/dev/null | sort)"
fi

# ── Find idea files ────────────────────────────────────────────
find_ideas() {
  case "${IDEA_FILTER:-all}" in
    folder)
      IFS=',' read -ra FOLDERS <<< "$IDEA_FOLDERS"
      for folder in "${FOLDERS[@]}"; do
        folder="${folder#"${folder%%[![:space:]]*}"}"
        folder="${folder%"${folder##*[![:space:]]}"}"
        if [[ -d "$IDEAS_PATH/$folder" ]]; then
          find "$IDEAS_PATH/$folder" -maxdepth 1 -name "*.md" -type f 2>/dev/null
        fi
      done
      ;;
    *)
      find "$IDEAS_PATH" -maxdepth 1 -name "*.md" -type f 2>/dev/null
      ;;
  esac
}

# ── Use awk to process all files at once ───────────────────────
# Feed file list to a single awk invocation that handles all parsing,
# JSON escaping, slug derivation, demo matching, and sorting.

IDEA_TAG=""
[[ "${IDEA_FILTER:-all}" == "tag" ]] && IDEA_TAG="$(get_config idea_tag)"

FILE_LIST="$(find_ideas | sort)"
[[ -z "$FILE_LIST" ]] && { echo "[]" > "$IDEAS_JSON"; echo "Showcase rebuilt: 0 ideas"; exit 0; }

# Build JSON with awk — one process for all files
JSON="$(echo "$FILE_LIST" | awk -v demos="$DEMO_FILES" -v filter="${IDEA_FILTER:-all}" -v filter_tag="$IDEA_TAG" '
BEGIN {
  # Build demo lookup
  n_demos = split(demos, demo_arr, "\n")
  count = 0
}

{
  file = $0
  # Extract basename without .md
  n = split(file, path_parts, "/")
  basename_md = path_parts[n]
  sub(/\.md$/, "", basename_md)
  filename = basename_md

  # Read file and parse frontmatter
  in_fm = 0; fm_done = 0
  name = ""; slug = ""; summary = ""; stage = ""; tags_raw = ""
  tags_multiline = 0; first_content = ""

  while ((getline line < file) > 0) {
    if (line == "---") {
      if (in_fm) { fm_done = 1; in_fm = 0; }
      else if (!fm_done) { in_fm = 1 }
      continue
    }

    if (in_fm) {
      # Multiline tags continuation
      if (tags_multiline) {
        if (line ~ /^[[:space:]]+-/) {
          val = line
          sub(/^[[:space:]]+-[[:space:]]*/, "", val)
          if (tags_raw != "") tags_raw = tags_raw "," val
          else tags_raw = val
          continue
        } else {
          tags_multiline = 0
        }
      }

      # Skip lines without colon (e.g., list items for other fields)
      if (line !~ /:/) continue

      key = line
      sub(/:.*/, "", key)
      val = line
      sub(/^[^:]+:[[:space:]]*/, "", val)
      # Strip quotes
      gsub(/^["'"'"']|["'"'"']$/, "", val)

      if ((key == "name" || key == "title") && name == "") name = val
      else if (key == "slug") slug = val
      else if (key == "summary") summary = val
      else if (key == "stage") stage = val
      else if (key == "tags") {
        if (val ~ /^\[/) {
          # Inline array [tag1, tag2]
          gsub(/[\[\]]/, "", val)
          tags_raw = val
        } else if (val == "") {
          tags_multiline = 1
        }
      }
      continue
    }

    # After frontmatter — first meaningful content line
    if (fm_done && first_content == "") {
      trimmed = line
      gsub(/^[[:space:]]+/, "", trimmed)
      if (trimmed != "" && trimmed !~ /^#/ && trimmed != "---" && trimmed !~ /^\[\[.*\]\]$/) {
        first_content = trimmed
      }
    }
  }
  close(file)

  # Skip files with no frontmatter
  if (!fm_done && !in_fm) next

  # Apply filters
  if (filter == "tag" && tags_raw !~ filter_tag) next
  if (filter == "stage" && stage == "") next

  # Derive slug from filename
  if (slug == "") {
    slug = filename
    # Strip JD prefix like "11.01 " or "11.68-"
    gsub(/^[0-9]+(\.[0-9]+)*[- ]+/, "", slug)
    # Lowercase and kebab-case
    slug = tolower(slug)
    gsub(/[[:space:]]/, "-", slug)
    gsub(/[^a-z0-9-]/, "", slug)
    gsub(/-+/, "-", slug)
    gsub(/^-|-$/, "", slug)
  }

  # Derive title from filename
  if (name == "") {
    name = filename
    gsub(/^[0-9]+(\.[0-9]+)*[- ]+/, "", name)
  }

  # Defaults
  if (stage == "") stage = "seedling"
  if (summary == "" && first_content != "") summary = first_content

  # Stage order
  if (stage == "building") sorder = 0
  else if (stage == "ready-to-build") sorder = 1
  else if (stage == "spec") sorder = 2
  else if (stage == "mock") sorder = 3
  else if (stage == "exploring") sorder = 4
  else if (stage == "seedling") sorder = 5
  else if (stage == "launched") sorder = 6
  else if (stage == "sprout") sorder = 7
  else if (stage == "sapling") sorder = 8
  else if (stage == "tree") sorder = 9
  else if (stage == "archived") sorder = 10
  else sorder = 99

  # Build tags JSON
  tags_json = "[]"
  if (tags_raw != "") {
    n_tags = split(tags_raw, tag_arr, ",")
    tags_json = "["
    for (t = 1; t <= n_tags; t++) {
      tag = tag_arr[t]
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", tag)
      if (tag == "") continue
      gsub(/\\/, "\\\\", tag)
      gsub(/"/, "\\\"", tag)
      if (t > 1 && tags_json != "[") tags_json = tags_json ","
      tags_json = tags_json "\"" tag "\""
    }
    tags_json = tags_json "]"
  }

  # Match demo files
  demos_json = "[]"
  demo_match = ""
  for (d = 1; d <= n_demos; d++) {
    if (demo_arr[d] != "" && index(demo_arr[d], slug) == 1) {
      if (demo_match != "") demo_match = demo_match ","
      dm = demo_arr[d]
      gsub(/\\/, "\\\\", dm)
      gsub(/"/, "\\\"", dm)
      demo_match = demo_match "\"" dm "\""
    }
  }
  if (demo_match != "") demos_json = "[" demo_match "]"

  # JSON-escape strings
  gsub(/\\/, "\\\\", slug); gsub(/"/, "\\\"", slug)
  gsub(/\\/, "\\\\", name); gsub(/"/, "\\\"", name)
  gsub(/\\/, "\\\\", summary); gsub(/"/, "\\\"", summary)
  gsub(/\\/, "\\\\", stage); gsub(/"/, "\\\"", stage)

  # Output with sort prefix
  printf "%d_%s\t{\"id\":\"%s\",\"title\":\"%s\",\"summary\":\"%s\",\"stage\":\"%s\",\"tags\":%s,\"demos\":%s}\n", \
    sorder, tolower(name), slug, name, summary, stage, tags_json, demos_json
}')"

# Sort and assemble JSON array
SORTED="$(echo "$JSON" | sort -t$'\t' -k1,1 | cut -f2-)"

RESULT="["
FIRST=1
while IFS= read -r obj; do
  [[ -z "$obj" ]] && continue
  [[ $FIRST -eq 0 ]] && RESULT+=","
  RESULT+="$obj"
  FIRST=0
done <<< "$SORTED"
RESULT+="]"

# ── Write ideas.json ──────────────────────────────────────────
printf '%s\n' "$RESULT" > "$IDEAS_JSON"

# ── Generate showcase HTML ────────────────────────────────────
JSON_TMP="$(mktemp)"
printf '%s' "$RESULT" > "$JSON_TMP"

awk -v jsonfile="$JSON_TMP" '
  /\/\*__IDEAS_DATA__\*\/\[\]/ {
    idx = index($0, "/*__IDEAS_DATA__*/[]")
    prefix = substr($0, 1, idx - 1)
    suffix_start = idx + length("/*__IDEAS_DATA__*/[]")
    suffix = substr($0, suffix_start)
    printf "%s/*__IDEAS_DATA__*/", prefix
    while ((getline line < jsonfile) > 0) printf "%s", line
    printf "%s\n", suffix
    next
  }
  { print }
' "$TEMPLATE" > "$SHOWCASE_PATH"

rm -f "$JSON_TMP"

# ── Report ─────────────────────────────────────────────────────
COUNT="$(printf '%s' "$RESULT" | grep -o '"id"' | wc -l | tr -d ' ')"
echo "Showcase rebuilt: $COUNT ideas → $SHOWCASE_PATH"
