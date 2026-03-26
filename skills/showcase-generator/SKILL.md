---
name: showcase-generator
description: Regenerate the Idea Lab showcase HTML from all idea markdown files. Runs a bundled shell script that scans ideas, builds JSON, and injects it into the HTML template. Called internally by other skills after creating or updating ideas. Can also be invoked directly with "regenerate showcase" or "update showcase".
version: 0.4.0
---

# Showcase Generator

## CRITICAL: This skill is a single Bash command. Nothing else.

**Run this and you are done:**

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/rebuild-showcase.sh"
```

That's it. Report the script's output to the user. Do NOT do anything else.

**DO NOT:**
- Scan or read idea markdown files
- Parse frontmatter
- Build JSON
- Read or modify the HTML template
- Use agents or subagents
- Read the config file

The shell script handles ALL of that internally in ~100ms.

## When This Skill Runs

- **Internally:** Called by `/new-idea` and `/flesh-out` after creating or updating ideas
- **Explicitly:** User says "regenerate showcase", "update showcase", "rebuild showcase"

## Editing the Showcase Design

To change the showcase's look and feel, edit the template directly:
`${CLAUDE_PLUGIN_ROOT}/skills/showcase-generator/references/showcase-template.html`

Then run the script to apply changes.

$ARGUMENTS
