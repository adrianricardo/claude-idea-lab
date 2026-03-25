---
name: showcase-generator
description: Regenerate the Idea Lab showcase HTML from all idea markdown files. Reads ideas, parses frontmatter, builds a browsable UI with sidebar navigation, iframe demo loading, and "flesh out" copy-command buttons. Called internally by other skills after creating or updating ideas. Can also be invoked directly with "regenerate showcase" or "update showcase".
version: 0.1.0
---

# Showcase Generator

Rebuild the Idea Lab showcase HTML from the current set of idea markdown files.

## Configuration

Read paths from `.idea-lab.config.md` (search: `{cwd}/` → `~/.claude/` → `~/idea-lab/`):

```
ideas_path    — directory containing idea markdown files
demos_dir     — directory containing HTML demo files
showcase_path — where to write the showcase index.html
```

## When This Skill Runs

- **Internally:** Called by `/new-idea` and `/flesh-out` after creating or updating ideas
- **Explicitly:** User says "regenerate showcase", "update showcase", "rebuild showcase"

## Step 1 — Scan Ideas

Read all `.md` files in `{ideas_path}/`. For each file:

1. Parse YAML frontmatter to extract: `name`, `slug`, `summary`, `stage`, `created`, `demo`, `prototype`
2. Read the first log entry to get the idea description
3. Check if a matching demo exists at `{demos_dir}/{slug}.html`
4. Check if a matching prototype exists at `{demos_dir}/{slug}-prototype.html`

Build an array of idea objects sorted by created date (newest first).

## Step 2 — Generate Showcase HTML

Write a single self-contained HTML file to `{showcase_path}`. The file must:

### Structure
- **Sidebar** (left, 340px): header, idea list with stage badges
- **Main area** (right): either an idea detail view or an iframe loading a demo/prototype

### Sidebar Content
- Header: "Idea Lab" with a dot accent
- Subtitle: "{count} ideas" with stage breakdown
- List of ideas, each showing:
  - Idea name (bold)
  - One-line summary (secondary text)
  - Stage badge with color coding:
    - `seedling` — amber
    - `exploring` — amber
    - `spec` — purple
    - `mock` — purple
    - `building` — accent (coral)
    - `launched` — green

### Main Area — Tab Navigation
When an idea is selected, the main area shows a **tab bar** at the top with:

- **Demo** (default, selected first) — if a demo exists
- **Prototype** — if a prototype exists
- **Overview** — idea details and actions

Tab bar styling: minimal, bottom-border active indicator using accent color. Same pattern as sidebar tabs.

### Main Area — Demo Tab (Default)
- Full-width iframe loading the demo HTML from `demos/` (relative path)
- No chrome or back buttons — the tab bar handles navigation
- If no demo exists, this tab is hidden and Overview becomes the default

### Main Area — Prototype Tab
- Full-width iframe loading the prototype HTML from `demos/` (relative path)
- Only shown if a prototype exists

### Main Area — Overview Tab
- Idea name as heading
- Stage badge
- Summary
- Full idea description (from the latest log entry)
- "Flesh out" button that copies `/flesh-out {slug}` to clipboard with a toast notification: "Copied! Paste this into Claude Code"
- If a prototype exists: "Make Real" button (disabled, labeled "Coming in v2")

### Empty State
If no ideas exist yet:
- Centered message: "No ideas yet"
- Instruction: "Run `/new-idea` in Claude Code to capture your first idea"

### Design System

Follow the reference template in `${CLAUDE_PLUGIN_ROOT}/skills/showcase-generator/references/showcase-template.md` for the exact CSS variables, typography, and component styles. The design uses:

- **Font:** Inter (loaded from Google Fonts)
- **Colors:** Light theme with warm coral accent (#E8553A)
- **CSS Variables:** See reference template for full set
- **Animations:** fadeUp on content transitions, smooth sidebar hover states
- **Scrollbars:** Styled thin scrollbars on webkit

### Data Embedding

Embed the idea data as a JavaScript constant at the top of the `<script>` section:

```javascript
const IDEAS = [
  {
    name: "Idea Name",
    slug: "idea-name",
    summary: "One-liner summary",
    stage: "seedling",
    created: "2026-03-25",
    hasDemo: true,
    hasPrototype: false,
    demoPath: "demos/idea-name.html",
    prototypePath: null
  },
  // ...
];
```

Use relative paths for demo/prototype files (assumes showcase is at the parent of demos/).

## Step 3 — Verify

After writing the file, verify it exists:

```bash
ls -la {showcase_path}
```

Report how many ideas are in the showcase and offer to open it.

## Rules

- **Always overwrite** the existing showcase file — it's fully regenerated each time
- **Never modify idea markdown files** — this skill is read-only on ideas
- **Use relative paths** for demo files in the HTML (e.g., `demos/slug.html`)
- **Sort ideas** newest first by created date
- **The showcase must work offline** — no external dependencies except the Google Fonts link (which degrades gracefully)

$ARGUMENTS
