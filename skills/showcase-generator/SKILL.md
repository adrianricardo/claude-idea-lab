---
name: showcase-generator
description: Regenerate the Idea Lab showcase by running a shell script. One bash command — nothing else needed.
version: 0.4.2
---

# Showcase Generator

## Step 1 — Run the rebuild script

Use the Bash tool to execute this exact command:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/rebuild-showcase.sh"
```

## Step 2 — Report the output

Tell the user what the script printed (it reports how many ideas were found).

## That's it. There is no Step 3.

The script reads the config, scans files, builds JSON, and generates the HTML showcase automatically. You do not need to read any files, scan any directories, parse any frontmatter, or build any JSON. The script does all of that. Your only job is to run the one command above.

$ARGUMENTS
