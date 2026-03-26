# Ideas

Manage and browse your Idea Lab collection.

## Configuration

Read paths from `.idea-lab.config.md` (search: `{cwd}/` → `~/.claude/` → `~/idea-lab/`). If not found, tell the user to run `/idea-lab-setup` first.

## Commands

### `/ideas` (no args) — List all ideas

1. Read all `.md` files in `{ideas_path}/`
2. Parse frontmatter for: `name`, `slug`, `stage`, `demo`, `prototype`, `created`
3. Display as a formatted list:

```
## Idea Lab — {count} ideas

| Name | Stage | Demo | Prototype | Created |
|------|-------|------|-----------|---------|
| {name} | {stage badge} | {yes/no} | {yes/no} | {date} |
```

Sort by created date, newest first.

### `/ideas open` — Open the showcase

```bash
open {showcase_path}
```

If the showcase doesn't exist yet, tell the user to run `/idea-lab-setup`.

### `/ideas status` — Stage breakdown

Count ideas by stage and display:

```
## Idea Lab Status

- seedling: {n}
- exploring: {n}
- spec: {n}
- mock: {n}
- building: {n}
- launched: {n}

Total: {n} ideas, {n} with demos, {n} with prototypes
```

### `/ideas add` — Alias for /new-idea

Tell the user: "Use `/new-idea` to capture a new idea."

$ARGUMENTS
