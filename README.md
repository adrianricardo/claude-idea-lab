# Idea Lab

A Claude Code plugin for capturing, developing, and showcasing ideas.

Dump a raw idea → get it structured and saved → spar on it → see an interactive demo → flesh it out into a prototype. All from your terminal.

## Install

```bash
claude plugin add adrianricardo/claude-idea-lab
```

Then run `/setup` to configure where your ideas live.

## Quick Start

```
/setup                        # First-time config
/new-idea                     # Capture a new idea
/ideas open                   # Open the showcase in your browser
/flesh-out my-idea-name       # Deep dive → UX prototype
/ideas                        # List all ideas
/ideas status                 # Stage breakdown
```

## How It Works

### 1. Capture (`/new-idea`)
Describe your idea. The plugin recaps it back to confirm, saves it immediately as markdown, then optionally jams with you — starting with what's most exciting, then pressure-testing feasibility, viability, and simplification.

### 2. Demo (automatic)
After capturing, you're offered an auto-generated interactive HTML demo — a self-contained page that captures the single most compelling moment of your idea's user journey.

### 3. Showcase (automatic)
All your ideas live in a browsable HTML showcase with a sidebar, stage badges, and iframe-loaded demos. Open it anytime with `/ideas open`.

### 4. Flesh Out (`/flesh-out`)
Go deeper. A focused interview covers target users, core flow, key screens, and data shape. Then a multi-screen UX prototype is generated — realistic-looking but with hardcoded data. No real logic, just the experience.

## Idea Lifecycle

Ideas move through stages:

```
seedling → exploring → spec → mock → building → launched
```

Stage changes always require your confirmation.

## Idea Format

Ideas are stored as markdown with YAML frontmatter and log-based entries:

```markdown
---
name: My Idea
slug: my-idea
summary: One-liner
stage: seedling
created: 2026-03-25
demo: true
prototype: false
---

## Log — March 25, 2026

### Sparring Insights
Key decisions from the spar...

## Log — March 25, 2026

### Initial Idea
The original idea as captured...
```

Log entries are append-only — the evolution of the idea is always visible.

## Configuration

After `/setup`, config is written to two places:

1. **`~/.claude/idea-lab.config.md`** — global, so `/new-idea` works from any repo
2. **`{ideas_dir}/.idea-lab.config.md`** — local, so the config travels with your data

```yaml
---
ideas_dir: ~/idea-lab
demos_dir: ~/idea-lab/demos
ideas_path: ~/idea-lab/ideas
showcase_path: ~/idea-lab/index.html
---
```

You can decline the global config during setup if you prefer local-only.

## v2 Roadmap

- Obsidian vault integration
- `/make-real` — add real logic and data to prototypes
- Pipeline tracking across stages
- Import/scan existing repos for demos
- Cross-skill wiring with your existing setup
