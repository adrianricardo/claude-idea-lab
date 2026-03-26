---
name: flesh-out
description: Take an existing idea and flesh it out through a deeper interview, then generate a UX-only multi-screen prototype with hardcoded data. Use when the user says "flesh out", "flesh out this idea", pastes "/flesh-out idea-name" from the showcase, or wants to go deeper on an existing idea.
version: 0.1.0
---

# Flesh Out

Take a captured idea and develop it further through a deep interview, then generate a UX-only prototype.

## Configuration

Read paths from `.idea-lab.config.md` (search: `{cwd}/` → `~/.claude/` → `~/idea-lab/`). If not found, tell the user to run `/idea-lab-setup`.

```
ideas_path    — directory containing idea markdown files
demos_dir     — directory containing HTML demo files
showcase_path — path to the showcase index.html
```

## Step 1 — Find the Idea

If invoked with an argument (e.g., `/flesh-out collaborative-canvas`), search for a matching `.md` file in `{ideas_path}/` by slug.

If no argument, list all ideas with their names and stages using **AskUserQuestion** and let the user pick.

If ambiguous (multiple partial matches), present options via **AskUserQuestion**.

Read the full idea markdown file to get all context (frontmatter, all log entries).

## Step 2 — Deep Interview

Conduct a focused interview using **AskUserQuestion** (one question at a time). The goal is to gather enough detail to build a realistic-looking multi-screen prototype.

Cover these areas, prioritizing what the idea most needs:

1. **Target user** — Who exactly uses this? What's their current workflow?
2. **Core flow** — Walk me through what the user does, step by step
3. **Key screens** — What are the 3-5 most important views/screens?
4. **Differentiation** — What makes this noticeably different from alternatives?
5. **Data shape** — What kind of content/data does the user see? (So we can create realistic hardcoded data)
6. **Edge cases** — What happens when X? What about Y? (Pick the most revealing edge cases)
7. **Simplification** — Can any of these screens be combined? What's the minimum viable flow?

Ask **7-12 questions total**. Start with the highest-leverage question. Don't ask what's already answered in the log entries. Stop when you have enough to build.

## Step 3 — Update Idea with Log Entry

Add a new log entry to the idea markdown file (above previous entries — newest first):

```markdown
## Log — {Month DD, YYYY}

### Flesh Out: Deep Dive
**Target user:** {who}
**Core flow:** {step by step}
**Key screens:** {list}
**Key decisions:** {simplifications, cuts, pivots from interview}
```

**Never modify or delete previous log entries.**

Update frontmatter:
- Set `prototype: true`
- Advance `stage` to `exploring` if still `seedling` (use **AskUserQuestion** to confirm the stage change first)

## Step 4 — Build UX Prototype

Create a **single self-contained HTML file** at `{demos_dir}/{slug}-prototype.html`.

### What a UX Prototype Is

- **Multi-screen:** 3-5 views the user can navigate between
- **Realistic data:** Hardcoded but believable content (real-looking names, numbers, text)
- **Interactive navigation:** Click to move between screens, tabs, modals
- **UX only:** No real logic, no API calls, no data persistence
- **Looks like a real product** — not a wireframe, not a mockup

### Design Standards

Follow `${CLAUDE_PLUGIN_ROOT}/skills/showcase-generator/references/demo-style-guide.md`:
- Light theme, Inter font, warm coral accent
- Smooth transitions between screens
- Micro-interactions on buttons and interactive elements
- Progressive disclosure

### Screen Navigation Pattern

Use a simple state-based approach:

```javascript
let currentScreen = 'home';
function showScreen(name) {
  document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
  document.querySelector(`[data-screen="${name}"]`).classList.add('active');
  currentScreen = name;
}
```

Each screen is a `<div class="screen" data-screen="name">` that shows/hides.

### What NOT to Include
- No real API calls or fetch requests
- No local storage or data persistence
- No real authentication flows
- No complex state management
- No build tools or external dependencies

## Step 5 — Rebuild Showcase

Run the rebuild script to regenerate the showcase with the updated idea:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/rebuild-showcase.sh"
```

The prototype should appear as a "View Prototype" button on the idea's detail page.

## Step 6 — Report

```
## Idea Fleshed Out

**Name:** {name}
**Stage:** {stage}
**Prototype:** {demos_dir}/{slug}-prototype.html
**Screens:** {list of screen names}

Open showcase: /ideas open
```

## Rules

- **Read all existing log entries** before interviewing — don't re-ask what's already been explored
- **Log-based updates only** — never overwrite previous entries
- **One question at a time** via AskUserQuestion — don't dump all questions at once
- **Confirm stage changes** — use AskUserQuestion before advancing stage
- **The prototype is UX only** — no real logic, no real data, no API calls
- **Hardcode everything** — use realistic but fake data throughout

$ARGUMENTS
