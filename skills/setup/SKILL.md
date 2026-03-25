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

**Question 1:** "Where should your ideas be stored? This is where markdown idea files and HTML demos will live. Default: `~/idea-lab`"
- Use a **free-text** AskUserQuestion — do NOT present preset path options
- The user might type a path, drag a folder into the terminal, or paste from clipboard
- Accept any valid path. If they just press enter or say "default", use `~/idea-lab`
- Resolve `~` to the full home directory path. Resolve relative paths to absolute.
- Verify the parent directory exists before proceeding

**Question 2:** "Do you have an existing folder with ideas or notes you'd like to import later? You can type or drag a folder path, or just say no if starting fresh."
- Use a **free-text** AskUserQuestion — let them type, drag, or paste a path
- If they provide a path, verify it exists. If it doesn't, tell them and re-ask.
- If yes, note the path in config for v2 import. Don't import now — just record it.
- If no, move on.

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
ideas_dir: {ideas_dir}
demos_dir: {ideas_dir}/demos
ideas_path: {ideas_dir}/ideas
showcase_path: {ideas_dir}/index.html
existing_notes_path: {path or null}
---

# Idea Lab Configuration

- Ideas stored at: {ideas_dir}/ideas
- Demos generated at: {ideas_dir}/demos
- Showcase at: {ideas_dir}/index.html
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
