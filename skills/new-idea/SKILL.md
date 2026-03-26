---
name: new-idea
description: Capture a new idea using an interview protocol. Recaps the idea, saves immediately as markdown with log-based format, optionally jams on excitement/feasibility/viability/simplification, generates an interactive demo, and rebuilds the showcase. Use when the user says "new idea", "I have an idea", "capture this idea", or invokes /new-idea.
version: 0.1.0
---

# New Idea

Capture a new idea using the full idea protocol: recap, save, jam, demo.

## Configuration

Read paths from `.idea-lab.config.md` (search: `{cwd}/` → `~/.claude/` → `~/idea-lab/`). If not found, tell the user to run `/idea-lab-setup` first.

```
ideas_path   — where markdown idea files live
demos_dir    — where HTML demos are saved
showcase_path — path to the showcase index.html
```

## Step 1 — Recap

Start with a brief plain-text recap of the idea as understood, to confirm alignment. Keep it concise — just enough to show you got it.

If invoked with an argument (e.g., `/new-idea Collaborative Canvas`), use that as the starting point. If the idea was described in the conversation, recap from context.

If there's no clear idea in context and no argument, use **AskUserQuestion** to ask: "What's the idea?"

## Step 2 — Save Immediately

Save the idea to `{ideas_path}/{slug}.md` **before any further discussion**. Don't wait for sparring — capture first.

### Markdown Format

```markdown
---
name: {Idea Name}
slug: {kebab-case-slug}
summary: {One-liner summary}
stage: seedling
created: {YYYY-MM-DD}
demo: false
prototype: false
---

## Log — {Month DD, YYYY}

### Initial Idea
{The idea as recapped in Step 1, expanded slightly with any details from context}
```

### Slug Rules
- kebab-case, derived from the idea name
- Short but recognizable (e.g., "collaborative-canvas", "idea-capture-studio")
- No numbers or dates in the slug

## Step 3 — Check Intent

Use the **AskUserQuestion** tool to ask:

"Idea saved. Want to jam on this (I'll dig into what's exciting, then pressure-test feasibility, viability, and simplification) — or just save and move on?"

Options:
- **Jam** — proceed to Step 4
- **Save and move on** — skip to Step 6

## Step 4 — Jam

Using the **AskUserQuestion** tool, ask the most impactful open questions that affect:

1. **Excitement** — what's the most exciting part of this idea? What makes you light up about it? Start here — understand the energy before testing the edges.
2. **Feasibility** — can this actually be built/done?
3. **Viability** — is there a real path to validation?
4. **Simplification** — what can be cut, merged, or elegantly reduced?

The goal is to help make the idea **launchable and validatable soon**. Prioritize:
- Understanding what makes this idea exciting — protect that core energy
- Identifying and solving the biggest gotchas, risks, or complexities
- Simplifying — make it smarter, more efficient, more elegant, more minimal
- Getting to a version that can be launched and validated quickly

Ask the **fewest, highest-leverage questions**. Do not ask obvious things. Start with excitement first — then move to the harder questions. Ask one question at a time using AskUserQuestion.

Continue jamming until you've covered the key angles (typically 4-6 questions). Don't overstay — when the core tensions are resolved, move on.

## Step 5 — Update with Jam Insights

After jamming, add a **new log entry** to the idea file (above the initial one — newest first):

```markdown
## Log — {Month DD, YYYY}

### Jam Session
**What's exciting:** {the core energy and excitement}
**Key decisions:** {simplifications, cuts, pivots}
**Resolved tensions:** {gotchas and risks addressed}

## Log — {earlier date}

### Initial Idea
{Original idea — untouched}
```

**Never modify or delete the Initial Idea entry.** The log is append-only history.

Also update the `summary` in frontmatter if the jam significantly changed the direction.

## Step 6 — Build Demo

### Identify Compelling Moments

Analyze the idea and identify 2-3 candidate moments from the user journey. Focus on:

- **The "aha" moment** — the instant the user understands what makes this different
- **The core interaction** — the single action that defines the product
- **The magic moment** — where the user first sees the value delivered

Present these as options using **AskUserQuestion**. Each option should have:
- A short label (the moment name)
- A description of what the demo would show

**Always include a final option: "Skip demo generation for now".**

If the user skips, jump directly to Step 7 (rebuild showcase) and Step 8 (report). The idea is still captured and will appear in the showcase without a demo.

### Build It

Create a **single self-contained HTML file** with inline CSS and JS.

**Design Standards:**
- Light aesthetic: clean whites, Inter font, warm accent colors
- Simplicity: one primary interaction per view, progressive disclosure
- Fluidity: animate transitions, no instant show/hide
- Delight: micro-interactions, satisfying feedback
- Looks like a real product, not a wireframe
- Someone who sees it should immediately understand the idea
- The interaction should be satisfying enough that they want to play with it

**Save to:** `{demos_dir}/{slug}.html`

**Update frontmatter:** Set `demo: true` in the idea's markdown file.

## Step 7 — Rebuild Showcase

Invoke the **showcase-generator** skill to regenerate the showcase HTML with the new idea included.

## Step 8 — Report

```
## Idea Captured

**Name:** {name}
**Stage:** seedling
**File:** {ideas_path}/{slug}.md
**Demo:** {demos_dir}/{slug}.html (or "none — run /flesh-out {slug} later")

Open showcase: /ideas open
```

## Rules

- **Always save before jamming** — never lose an idea to a long conversation
- **Log-based updates only** — never overwrite previous log entries
- **Never skip the recap** — confirm alignment before saving
- **Ask one jam question at a time** — don't dump all questions at once
- **Stage is always seedling** for new ideas — never auto-advance
- **Use AskUserQuestion** for all interactions — never ask as inline text

$ARGUMENTS
