---
name: showcase-generator
description: Regenerate the Idea Lab showcase HTML from all idea markdown files. Reads ideas, parses frontmatter, builds a JSON array, and injects it into the HTML template. Called internally by other skills after creating or updating ideas. Can also be invoked directly with "regenerate showcase" or "update showcase".
version: 0.2.0
---

# Showcase Generator

Rebuild the Idea Lab showcase by scanning idea files and injecting data into the HTML template.

## Configuration

Read paths from `.idea-lab.config.md` (search: `{cwd}/` → `~/.claude/` → `~/idea-lab/`). The filename is always `.idea-lab.config.md` (with leading dot) in all locations.

```
ideas_path    — directory containing idea markdown files
demos_dir     — directory containing HTML demo files
showcase_path — where to write the showcase index.html
```

## When This Skill Runs

- **Internally:** Called by `/new-idea` and `/flesh-out` after creating or updating ideas
- **Explicitly:** User says "regenerate showcase", "update showcase", "rebuild showcase"

## Step 1 — Scan Ideas

Read `.md` files from `{ideas_path}/`, applying the configured `idea_filter`:
- **`folder`**: only scan files in `idea_folders` subfolders
- **`tag`**: scan all files, only include those with `idea_tag` in frontmatter `tags`
- **`stage`**: scan all files, only include those with a `stage` field in frontmatter
- **`all`**: scan all files with frontmatter
- **No filter set (standalone mode)**: read all files in `{ideas_path}/`

For each matched file:

1. Parse YAML frontmatter. **Skip files with no frontmatter**.
2. Extract fields:
   - `id` — from frontmatter `slug`, or derive from filename (kebab-case, strip leading numbers like `11.68-`)
   - `title` — from frontmatter `name` or `title`, or derive from filename
   - `summary` — from frontmatter, or first non-heading line of content
   - `stage` — from frontmatter, default `seedling`
   - `tags` — from frontmatter, default `[]`
   - `demos` — list of matching demo filenames found at `{demos_dir}/{slug}*.html`
3. Sort by stage order (building → ready-to-build → spec → exploring → seedling), then alphabetically within stage.

Build a JSON array of idea objects.

## Step 2 — Inject Data into Template

1. Read the HTML template at `${CLAUDE_PLUGIN_ROOT}/skills/showcase-generator/references/showcase-template.html`
2. Find the data placeholder: `/*__IDEAS_DATA__*/[]`
3. Replace it with the JSON array from Step 1: `/*__IDEAS_DATA__*/[{...}, ...]`
4. Write the result to `{showcase_path}`

**Important:** Do NOT modify any HTML, CSS, or JavaScript in the template. Only replace the data placeholder.

## Step 3 — Verify

```bash
ls -la {showcase_path}
```

Report how many ideas are in the showcase.

## Rules

- **Only replace the data placeholder** — never modify template HTML/CSS/JS
- **Never modify idea markdown files** — this skill is read-only on ideas
- **Use relative paths** for demo files (e.g., `demos/slug.html`) — the showcase sits at the parent of `demos/`
- **Sort ideas** by stage order, then alphabetically

## Editing the Showcase Design

To change the showcase's look and feel, edit the template directly:
`${CLAUDE_PLUGIN_ROOT}/skills/showcase-generator/references/showcase-template.html`

Then regenerate to apply changes.

$ARGUMENTS
