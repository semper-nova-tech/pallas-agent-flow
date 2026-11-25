# Terminal tools fixture

## Input

Run `order-submission` with `claude.normal`. Session A runs inside Herdr with glow,
Skema 0.3.4 and the `pallas.skema` plugin, and Hunk; TTT is not installed. Session B
resumes the same run outside Herdr. The human already has a tab labelled
`order-submission spec` open from an earlier checkpoint.

## Expected in session A

`run.md` header at intake:

```md
- tools: herdr yes; glow yes; skema 0.3.4; hunk yes; ttt no
```

One line, once, at intake: `TTT is not installed; code is named as path:line instead.`

Requirements approval checkpoint:

- `docs/features/order-submission/diagrams/order-flow.json` and `order-flow.svg` exist;
  `architecture-overview.md` embeds the SVG under `### Order flow`.
- The orchestrator reuses the `order-submission spec` tab and reruns glow there, opens
  `order-submission architecture` with glow and `order-submission diagram order-flow`
  with the Skema Editor, all with `--no-focus`.
- The planner worker opened no tab; it returned the paths.

Post-build review of PR-02 opens `order-submission pr-02 diff` running
`hunk diff main...order-submission-backend` in that PR's worktree.

## Expected in session B

On resume, `tools` becomes `herdr no; glow yes; skema 0.3.4; hunk yes; ttt no`. One line
names Herdr as missing. Checkpoints print each path with `glow -t <abs-path>`, and the
PR diff with `hunk diff main...order-submission-backend`. No tab is closed, no tool is
installed, and every approval and check proceeds as in session A.

## Explicit no-tools case

With none of the tools present, diagrams are Mermaid blocks per the diagram policy, PR
diffs are a `git diff --stat` summary with the hunks that matter, and the run reaches
the same checkpoints.
