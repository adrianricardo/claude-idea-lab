---
name: setup
description: First-run setup for Idea Lab. Asks where to store ideas, creates directories, and writes configuration. Use when the user says "setup idea lab", "configure idea lab", or when any idea-lab skill runs and no config exists yet.
version: 0.1.0
---

# Idea Lab Setup

Configure Idea Lab for first-time use. Creates the directory structure and writes a config file that all other skills read from.

## When This Skill Runs

- Explicitly: user says `/setup` or "set up idea lab"
- Automatically: any other idea-lab skill detects missing config

## Step 1 — Check for Existing Config

Search for config in these locations (first match wins):
1. `{cwd}/.idea-lab.config.md` — local to current project
2. `~/.claude/idea-lab.config.md` — global (works from any repo)
3. `~/idea-lab/.idea-lab.config.md` — default ideas directory

If found, read and display the current config, then use **AskUserQuestion** to ask if they want to reconfigure.

If it exists and they don't want to change it, stop here.

## Step 2 — Ask Configuration Questions

Use the **AskUserQuestion** tool for each question. Do NOT ask all at once — ask sequentially so each answer can inform the next.

**Question 1:** "Where should your ideas be stored? This is where markdown idea files and HTML demos will live. You can also point this to an existing folder (like an Obsidian vault subfolder). Default: `~/idea-lab`"
- Use a **free-text** AskUserQuestion — do NOT present preset path options
- The user might type a path, drag a folder into the terminal, or paste from clipboard
- Accept any valid path. If they just press enter or say "default", use `~/idea-lab`
- Resolve `~` to the full home directory path. Resolve relative paths to absolute.
- Verify the parent directory exists before proceeding

**After getting the path — Detect Obsidian:**

Check if the provided path (or any parent up to 3 levels) contains a `.obsidian/` folder.

If Obsidian detected, set `mode: obsidian` in config and ask a follow-up:

**Obsidian Question:** "Your vault might have ideas mixed in with other notes. How should I find your ideas?"
- Use AskUserQuestion with these options:
  1. **By folder** — "Only look in specific folders" → ask which subfolder(s) hold ideas (free-text, comma-separated). Store as `idea_folders` in config.
  2. **By tag** — "Notes tagged with a specific tag" → ask which tag (e.g., `#idea`, `#project`). Store as `idea_tag` in config.
  3. **By stage field** — "Notes that have a `stage` field in frontmatter" → no extra config needed, filter by frontmatter.
  4. **Everything** — "Treat all markdown files in this path as ideas" → no filter.

Then adjust behavior:
- `ideas_path` = the provided path directly (don't create an `ideas/` subfolder)
- `demos_dir` = `{ideas_dir}/demos` (create this inside the vault folder for demo HTML files)
- When scanning for idea files, apply the chosen filter:
  - **By folder:** only scan `.md` files in the specified subfolder(s)
  - **By tag:** only include files whose frontmatter `tags` array contains the specified tag
  - **By stage field:** only include files that have a `stage` field in frontmatter
  - **Everything:** include all `.md` files with frontmatter
- For all matched files, handle missing fields gracefully:
  - If `slug` is missing: derive from filename (kebab-case, strip leading numbers like `11.68-`)
  - If `stage` is missing: default to `seedling`
  - If `demo`/`prototype` is missing: default to `false`
  - If `summary` is missing: use the first non-heading line of content
  - If the file has no YAML frontmatter at all: skip it (not an idea file)
- **Never rewrite existing vault notes** to add missing fields. Read gracefully, write only when the user explicitly creates or updates via plugin skills.

If NOT an Obsidian vault, use the standard setup:
- `mode: standalone`
- Create `{ideas_dir}/ideas/` and `{ideas_dir}/demos/`
- `ideas_path` = `{ideas_dir}/ideas`

## Step 3 — Create Directory Structure

```bash
mkdir -p {ideas_dir}/ideas
mkdir -p {ideas_dir}/demos
```

## Step 4 — Write Config Files

Write the config to **two locations**:

1. **`~/.claude/idea-lab.config.md`** — global, so the plugin works from any repo
2. **`{ideas_dir}/.idea-lab.config.md`** — local, so the config travels with the data

Both files have the same content:

```markdown
---
mode: {standalone or obsidian}
ideas_dir: {ideas_dir}
demos_dir: {ideas_dir}/demos
ideas_path: {ideas_path}
showcase_path: {ideas_dir}/index.html
idea_filter: {folder, tag, stage, or all}
idea_folders: {comma-separated subfolder paths, if filter is folder}
idea_tag: {tag name, if filter is tag}
---

# Idea Lab Configuration

- Mode: {standalone or obsidian}
- Ideas stored at: {ideas_path}
- Demos generated at: {ideas_dir}/demos
- Showcase at: {ideas_dir}/index.html
- Filter: {description of how ideas are identified}
```

Use **AskUserQuestion** to confirm before writing the global config to `~/.claude/`. If the user declines, only write the local one.

## Step 5 — Initialize Showcase

Invoke the **showcase-generator** skill to create an empty showcase HTML at `{showcase_path}`. If no ideas exist yet, it should show a welcome state.

## Step 6 — Report

Tell the user:
- Where their ideas will be stored
- How to capture their first idea: `/new-idea`
- How to open the showcase: `/ideas open`

## Reading Config (For Other Skills)

All idea-lab skills should read config like this:

1. Search for config in: `{cwd}/.idea-lab.config.md` → `~/.claude/idea-lab.config.md` → `~/idea-lab/.idea-lab.config.md`
2. Parse the YAML frontmatter for paths
3. If not found anywhere, tell the user to run `/setup` first (or trigger it automatically)

$ARGUMENTS
