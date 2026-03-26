---
name: ideas
description: Manage and browse your Idea Lab collection. List ideas, open the showcase, or check status.
argument-hint: "[open | status]"
---

# Ideas

Manage and browse your Idea Lab collection.

## Configuration

Read paths from `.idea-lab.config.md` (search: `{cwd}/` → `~/.claude/` → `~/idea-lab/`). If not found, tell the user to run `/idea-lab-setup` first.

## Rebuild Script

All commands below should first run the rebuild script to ensure data is fresh:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/rebuild-showcase.sh"
```

This writes `ideas.json` alongside the showcase. Use that file as the data source for all commands below — do NOT scan individual idea files.

## Commands

### `/ideas` (no args) — List all ideas

1. Run the rebuild script
2. Read `{showcase_dir}/ideas.json`
3. Display as a formatted list:

```
## Idea Lab — {count} ideas

| Name | Stage | Demos |
|------|-------|-------|
| {title} | {stage} | {count} |
```

Sort by stage order (building → ready-to-build → spec → exploring → seedling), then alphabetically.

### `/ideas open` — Open the showcase

1. Run the rebuild script (ensures showcase is fresh)
2. Open the showcase:

```bash
open {showcase_path}
```

If the showcase doesn't exist yet, tell the user to run `/idea-lab-setup`.

### `/ideas status` — Stage breakdown

1. Run the rebuild script
2. Read `{showcase_dir}/ideas.json`
3. Count ideas by stage and display:

```
## Idea Lab Status

- building: {n}
- ready-to-build: {n}
- spec: {n}
- exploring: {n}
- seedling: {n}

Total: {n} ideas, {n} with demos
```

### `/ideas add` — Alias for /new-idea

Tell the user: "Use `/new-idea` to capture a new idea."

$ARGUMENTS
