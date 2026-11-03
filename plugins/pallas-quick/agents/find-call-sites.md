---
name: find-call-sites
description: Finds every use of a symbol, string, or config key for a quick change. Read-only.
tools: Read, Grep, Glob
model: haiku
---

# Contract

Search for every use of what the request names, including re-exports, string
references, templates, tests, and config.

Return one line per hit: `file:line` and what the use does. Group hits by project.
End with the search patterns you ran, so a gap is visible.
