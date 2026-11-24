# Review output

## Table

One table, ranked by impact. `Now` and `Suggest` hold code, names, or paths, not prose.

```markdown
## AI review: renames and simplifications

| # | Kind | Where | Now | Suggest | Why |
| --- | --- | --- | --- | --- | --- |
| 1 | rename | `src/orders/load.ts:42` | `get(id)` | `fetchOrder(id)` | Says what it loads; 3 callers |
| 2 | simplify | `src/orders/order-service.ts:10` | `OrderService` wrapping `fetchOrder` | call `fetchOrder` directly | Forwards one call, one caller |
| 3 | organize | `src/orders/` | 6 flat files | `src/orders/pricing/` for the 3 pricing files | Groups one role |
```

`Kind` is `rename`, `simplify`, or `organize`. A rename of an export says its caller
count in `Why`.

## Line comments

One entry per finding, grouped by file and in line order:

```markdown
`src/orders/load.ts:42`
Now: `const d = await get(id)`
Suggest: `const order = await fetchOrder(id)`
Why: `d` and `get` say nothing without the code around them.
```

Mark a finding on deleted code `old:` before the line number. Mark one on a line
outside the diff `(outside diff)`.

## Post

Write each payload to the scratch folder, then run `gh` from the worktree so
`{owner}/{repo}` resolve to its remote.

**Root-level**, one comment holding the table, then the line comments:

```bash
gh pr comment <number> --body-file <scratch>/review-comment.md
```

**Line-by-line**, one review with `event` set to `COMMENT`, never `APPROVE` or
`REQUEST_CHANGES`:

```bash
gh api repos/{owner}/{repo}/pulls/<number>/reviews --method POST --input <scratch>/review.json
```

```json
{
  "commit_id": "<head sha>",
  "event": "COMMENT",
  "body": "<the table, plus every finding outside the diff>",
  "comments": [
    { "path": "src/orders/load.ts", "line": 42, "side": "RIGHT",
      "body": "`d` and `get` say nothing without the code around them.\n\n```suggestion\n  const order = await fetchOrder(id)\n```" }
  ]
}
```

- `side` is `RIGHT` for added or unchanged lines and `LEFT` for an `old:` line. A span
  adds `start_line` and `start_side`.
- Use a `suggestion` block only when it replaces exactly the commented lines, with
  their indentation. Otherwise give `Suggest:` as text.
- A `422` names a line GitHub cannot place. Move those findings into `body` and send once
  more; report anything that still fails.
