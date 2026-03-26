---
name: idea-lab-setup
description: First-run setup for Idea Lab. Detects your environment, asks where ideas and demos live, and writes configuration. Use when the user says "idea lab setup", "configure idea lab", "/idea-lab-setup", or when any idea-lab skill runs and no config exists yet.
version: 0.2.0
---

# Idea Lab Setup

Configure Idea Lab for first-time use. Detects your environment, asks focused questions, and writes a config file that all other skills read from.

## When This Skill Runs

- Explicitly: user says `/idea-lab-setup` or "set up idea lab"
- Automatically: any other idea-lab skill detects missing config

## Step 1 — Check for Existing Config

Search for config in these locations (first match wins):
1. `{cwd}/.idea-lab.config.md` — local to current project
2. `~/.claude/idea-lab.config.md` — global (works from any repo)
3. `~/idea-lab/.idea-lab.config.md` — default ideas directory

If found, read and display the current config, then use **AskUserQuestion** to ask if they want to reconfigure.

If it exists and they don't want to change it, stop here.

## Step 2 — Detect Environment

Before asking anything, scan for signals:

1. Check for Obsidian vaults: look for `.obsidian/` folders in `~/` (1 level), `~/Code/` (2 levels), `~/Documents/` (2 levels)
2. Check for an existing `~/idea-lab/` or `~/Code/idea-lab/` or `~/Code/ideas-lab/` directory
3. Check for existing demo HTML files in any found directories

Build a summary of what was detected. This informs the questions below.

## Step 3 — Ask Configuration Questions

Use the **AskUserQuestion** tool for each question. Do NOT ask all at once — ask sequentially so each answer can inform the next.

### Question 1: Where do your ideas live?

Present what was detected, then ask. Examples:

- If an Obsidian vault was found: "I found an Obsidian vault at `{path}`. Are your ideas in there? If so, which subfolder? Or type a different path."
- If no vault detected: "Where should idea markdown files be stored? Default: `~/idea-lab`"
- If multiple vaults found: list them and ask which one

Use a **free-text** AskUserQuestion — do NOT present preset path options.
- The user might type a path, drag a folder into the terminal, or paste from clipboard
- Accept any valid path. If they just press enter or say "default", use `~/idea-lab`
- Resolve `~` to the full home directory path. Resolve relative paths to absolute
- Verify the path exists (or its parent exists) before proceeding

### Obsidian Follow-up (if vault detected)

Check if the provided path (or any parent up to 3 levels) contains a `.obsidian/` folder.

If Obsidian detected, set `mode: obsidian` in config and ask:

"Your vault has other notes besides ideas. How should I find your ideas?"
- Use AskUserQuestion with these options:
  1. **By folder** — "Only look in specific folders" → ask which subfolder(s) hold ideas (free-text, comma-separated). Store as `idea_folders` in config.
  2. **By tag** — "Notes tagged with a specific tag" → ask which tag (e.g., `#idea`, `#project`). Store as `idea_tag` in config.
  3. **By stage field** — "Notes that have a `stage` field in frontmatter" → no extra config needed, filter by frontmatter.
  4. **Everything** — "Treat all markdown files in this path as ideas" → no filter.

### Question 2: Where should demos and the showcase live?

This is where HTML demo files and the browsable showcase (index.html) are generated. For Obsidian users, this should typically be a **separate directory** to keep the vault clean.

Present what was detected:
- If `~/Code/ideas-lab/` or similar exists with demos: "I found existing demos at `{path}/demos/`. Use `{path}` for your showcase? Or type a different path."
- If no existing showcase dir: "Where should demos and the showcase live? Default: `~/idea-lab`" (for standalone) or "Default: `~/Code/idea-lab`" (for Obsidian users)

Use a **free-text** AskUserQuestion.

If NOT an Obsidian vault and the user gives the same path as Question 1, that's fine — demos and ideas co-locate.

## Step 4 — Resolve Paths

Based on the answers, resolve all paths:

**Obsidian mode:**
- `ideas_path` = the provided vault path directly (don't create an `ideas/` subfolder)
- `demos_dir` = `{showcase_dir}/demos`
- `showcase_path` = `{showcase_dir}/index.html`

**Standalone mode:**
- `ideas_path` = `{ideas_dir}/ideas`
- `demos_dir` = `{ideas_dir}/demos`
- `showcase_path` = `{ideas_dir}/index.html`

### Field handling for existing files

When scanning for idea files, apply the chosen filter:
- **By folder:** only scan `.md` files in the specified subfolder(s)
- **By tag:** only include files whose frontmatter `tags` array contains the specified tag
- **By stage field:** only include files that have a `stage` field in frontmatter
- **Everything:** include all `.md` files with frontmatter

For all matched files, handle missing fields gracefully:
- If `slug` is missing: derive from filename (kebab-case, strip leading numbers like `11.68-`)
- If `stage` is missing: default to `seedling`
- If `demo`/`prototype` is missing: default to `false`
- If `summary` is missing: use the first non-heading line of content
- If the file has no YAML frontmatter at all: skip it (not an idea file)

**Never rewrite existing vault notes** to add missing fields. Read gracefully, write only when the user explicitly creates or updates via plugin skills.

## Step 5 — Create Directory Structure

```bash
mkdir -p {demos_dir}
# For standalone mode only:
mkdir -p {ideas_path}
```

## Step 6 — Write Config Files

Write the config to **two locations**:

1. **`~/.claude/idea-lab.config.md`** — global, so the plugin works from any repo
2. **`{showcase_dir}/.idea-lab.config.md`** — local, so the config travels with the showcase

Both files have the same content:

```markdown
---
mode: {standalone or obsidian}
ideas_path: {ideas_path}
demos_dir: {demos_dir}
showcase_path: {showcase_path}
idea_filter: {folder, tag, stage, or all}
idea_folders: {comma-separated subfolder paths, if filter is folder}
idea_tag: {tag name, if filter is tag}
---

# Idea Lab Configuration

- Mode: {standalone or obsidian}
- Ideas stored at: {ideas_path}
- Demos generated at: {demos_dir}
- Showcase at: {showcase_path}
- Filter: {description of how ideas are identified}
```

Use **AskUserQuestion** to confirm before writing the global config to `~/.claude/`. If the user declines, only write the local one.

## Step 7 — Initialize Showcase

Invoke the **showcase-generator** skill to create the showcase HTML at `{showcase_path}`. It will scan existing ideas and demos. If no ideas exist yet, it should show a welcome state.

## Step 8 — Report

Tell the user:
- What was configured (ideas path, demos path, showcase path, filter)
- How many existing ideas were found (if any)
- How to capture their first idea: `/new-idea`
- How to open the showcase: `/ideas open`

## Reading Config (For Other Skills)

All idea-lab skills should read config like this:

1. Search for config in: `{cwd}/.idea-lab.config.md` → `~/.claude/idea-lab.config.md` → `~/idea-lab/.idea-lab.config.md`
2. Parse the YAML frontmatter for paths
3. If not found anywhere, tell the user to run `/idea-lab-setup` first (or trigger it automatically)

$ARGUMENTS
