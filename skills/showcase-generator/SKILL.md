---
name: showcase-generator
description: Regenerate the Idea Lab showcase HTML from all idea markdown files. Runs a bundled shell script that scans ideas, builds JSON, and injects it into the HTML template. Called internally by other skills after creating or updating ideas. Can also be invoked directly with "regenerate showcase" or "update showcase".
version: 0.4.0
---

# Showcase Generator

Rebuild the Idea Lab showcase by running the bundled rebuild script.

## When This Skill Runs

- **Internally:** Called by `/new-idea` and `/flesh-out` after creating or updating ideas
- **Explicitly:** User says "regenerate showcase", "update showcase", "rebuild showcase"

## How It Works

Run the shell script bundled with the plugin:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/rebuild-showcase.sh"
```

This script:
1. Reads config from `.idea-lab.config.md`
2. Scans all idea `.md` files and extracts frontmatter
3. Writes `ideas.json` alongside the showcase
4. Injects data into the HTML template and writes `index.html`

It runs in ~100ms and requires no other tools or dependencies.

## Output

The script writes two files:
- `{showcase_dir}/ideas.json` — structured data for all ideas
- `{showcase_path}` — self-contained HTML showcase with embedded data

## Rules

- **Just run the script** — do not manually scan files, parse frontmatter, or build JSON
- **Never modify the HTML template** — the script handles injection
- **Never modify idea markdown files** — this skill is read-only on ideas

## Editing the Showcase Design

To change the showcase's look and feel, edit the template directly:
`${CLAUDE_PLUGIN_ROOT}/skills/showcase-generator/references/showcase-template.html`

Then run the script to apply changes.

$ARGUMENTS
