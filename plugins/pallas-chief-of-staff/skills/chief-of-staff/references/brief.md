# Brief template

Write the brief to the path `report new` prints. Keep every heading, in this order.
Drop a section's body to one line, "Nothing.", when it has nothing. Never drop the
heading. Under 120 lines.

```markdown
# Brief — <Weekday, Month D, YYYY, HH:MM local>

<Headline: one to three sentences. What needs the human first, what finished, and the
one thing that changed direction. No counts here.>

## Needs you

1. **<thing>** — <evidence: pane id, PR url, issue key, or branch>. Next: <one action>.
2. ...

## Since last brief

<Since <last brief time>. Grouped by source. Merged PRs, agents that finished with their
last line, Linear issues that moved, commits by others on branches I touched,
roadmap or ledger changes.>

## Timeline

<Only when the watch pane collected more than one snapshot. One line per change with a
local time: agent state changes, PR opened or merged, check failed or recovered.
Otherwise: "No overnight collection.">

## In flight

### <repo label>
- `<branch>` in <worktree path or pane id> — <agent and status, or "no agent">.
  <ahead/behind default>, <dirty count>. Next: <one action>.

### Linear
- <KEY-123> <title> — <state>, <due>. Next: <one action>.

## Roadmap

<Per roadmap source. From project-manager when delegated, else from roadmap.md: Now
slugs with their stage, untracked work it found, the offer it made. Nothing is edited.>

## Sources

| Source | Kind | Pulled | Items | Note |
| --- | --- | --- | --- | --- |
| <label> | git | <UTC time> | <commits, PRs> | <fetch failed, gh unavailable, ok> |

Tools: <one line: which of Herdr, Pallas Agent Flow, Pallas Quick, Skema, gh, Linear,
glow were available>. Machine: <hostname>. Home: <path>.
```

Writing rules:

- Lead with the action, not the inventory. "PR #41 waits on your review" beats
  "There is one PR".
- One next action per item. Do not collapse two items into one line.
- Name the branch or pane once per line, in backticks.
- Quote a blocked agent's question verbatim, trimmed to one line.
- Counts go in Sources. The prose names things.
