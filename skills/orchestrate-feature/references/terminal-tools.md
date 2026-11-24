# Terminal Tools Policy

Show people what the run wrote, using the terminal tools they already have. None of
these tools is required, and the flow runs the same without any of them. Any skill that
puts a file, diagram, or diff in front of a human follows this policy by reference.

## Detect once

Detect at intake, or at the start of a skill a human invoked directly, and record the
result in the `tools` header field of `run.md`, or in the skill's own run evidence when
it keeps some.
Every later step reads that field and does not probe again. On resume, detect again and
name only tools that have gone missing since.

| Tool | Present when | Used for | Fallback |
| --- | --- | --- | --- |
| Herdr | `HERDR_ENV=1`, `herdr` is on `PATH`, and `herdr --version` succeeds | viewer tabs and panes for every tool below | print each path and the exact command the human can run |
| glow | `glow` is on `PATH` | reading published files, PRDs, PR notes, and reports | print the path |
| Skema | `skema --version` reports 0.3.3 or newer and the `skema-diagram` skill is listed; the Editor in Herdr also needs `pallas.skema` in `herdr plugin list` | design, domain model, and PR sequence diagrams | a Mermaid text diagram per [diagram-policy.md](diagram-policy.md), or none |
| Hunk | `hunk` is on `PATH`, `hunk session --help` succeeds, and the `cli-hunk` skill is listed | code diffs | a plain diff summary: `git diff --stat` and the hunks that matter |
| TTT | `ttt.editor` is in `herdr plugin list` and the `pallas-ttt` skill is listed | code a human reads or edits | name the file and line as `path:line` |

Without Herdr, a present tool still has a command worth printing: `glow -t <path>`,
`skema open-editor --manifest <abs>.json --svg <abs>.svg`, or `hunk diff <base>...<branch>`.

Name each missing tool once per run, in one line, with what the flow does instead. Do
not mention it again, work around it, or install it. Install a tool or a Herdr plugin
only when the human asks. This overrides the install and `--focus` defaults in the tool
skills.

## When to open

Open a viewer only when a human is asked to read something now:

- a PRD draft, technical spec, architecture overview, sequence, or PR note presented at
  an approval checkpoint
- a design diagram, once, when it is first created at a design stage
- a PR's diff at its post-build review or per-PR approval
- a final report
- a file a blocker or decision points at, or any file the human asks to see

Do not open a viewer for every file written. Workers never open viewers; they return the
paths, and the skill talking to the human opens them. When the human says not to open
tabs, record that as a constraint in `run.md` and stop opening them.

## Viewer tabs

A viewer tab is a named Herdr tab the flow opens in the current workspace, with `--cwd`
set to the target repository or the PR's worktree:

| Content | Tab label | Viewer |
| --- | --- | --- |
| PRD draft | `<feature-slug> prd` | glow |
| Technical spec | `<feature-slug> spec` | glow |
| Architecture overview | `<feature-slug> architecture` | glow |
| One design diagram | `<feature-slug> diagram <diagram-slug>` | Skema Editor |
| Sequence | `<feature-slug> sequence` | glow |
| PR note | `<feature-slug> pr-<nn>` | glow |
| PR diff | `<feature-slug> pr-<nn> diff` | Hunk |
| Final report | `<feature-slug> report` | glow |
| Portfolio status | `portfolio` | glow |

Labels are lowercase, stable for the whole run, and built from the feature slug and the
stage.

- glow: `herdr tab create --label <label> --cwd <dir> --no-focus`, then
  `herdr pane run <pane> "glow -t <abs-path>"` in the returned root pane.
- Skema: `herdr plugin pane open --plugin pallas.skema --entrypoint editor --placement tab
  --env SKEMA_MANIFEST=<abs>.json --no-focus`, then `herdr tab rename` to the label.
- Hunk: create the tab as for glow and run `hunk diff <base>...<branch>` in its pane.
- TTT: code opens in a TTT pane split beside the calling pane, never in the agent's own
  pane: `herdr plugin pane open --plugin ttt.editor --entrypoint editor --placement split
  --target-pane "$HERDR_PANE_ID" --env TTT_TARGET_DIR=<abs-path> --no-focus`.

Rules for every viewer:

- **Reuse before opening.** Read `herdr tab list --workspace "$HERDR_WORKSPACE_ID"` and
  reuse a tab whose label matches. The Skema Editor and a Hunk session reload in place
  (`hunk session reload`); for glow, quit the viewer in that tab's pane and run it again
  there. Never open a second tab with the same label.
- **Keep the human's focus.** Open with `--no-focus`. Focus a viewer only when the human
  asks to see it now. Say in one line which tab holds what.
- **Close nothing you did not open.** Viewer tabs stay open for the human to close. The
  flow only replaces a viewer it started in its own tab. Herdr adapter worker panes keep
  their own close rule.

## Project awareness

The target repository's conventions win. Its documentation home, diagram format, and
agent instructions decide where files live and what they look like; this policy only
decides how they are shown. Write no tool configuration into the target repository, and
never make a check, approval, or build depend on a viewer having opened.
