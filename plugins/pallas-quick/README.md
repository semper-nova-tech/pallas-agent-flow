# Pallas Quick

A lightweight mode for changes that fit in one PR: fixes, small enhancements,
dependency bumps, CI triage, audits, and doc fixes. Work that needs a PR sequence or
changes a shared contract belongs in Pallas Agent Flow, and `quick-change` hands it
off.

| Role | Model | Job |
| --- | --- | --- |
| Main session | Sonnet | Builds and applies changes |
| `map-repo`, `find-call-sites`, `audit-diff` | Haiku | Search, call-site sweeps, checks and diff review |
| Advisor or `sign-off` | Opus | Plan, repeated failure, and done decisions |

## Use

Install the `pallas-quick` plugin from this repo. Cursor reads
`.cursor-plugin/marketplace.json`; Claude Code reads `.claude-plugin/marketplace.json`.

```bash
claude --model sonnet --advisor opus
```

Then run `/pallas-quick:quick-change <request>`. Without `--advisor`, the skill uses
the `sign-off` agent for the Opus decisions. In Cursor, install the plugin and run
the same slash command.

## Diff code review

`/pallas-quick:diff-code-review <PR number, URL, or branch>` reviews one change without
touching your checkout. It pulls the change into a worktree, diagrams the changed code by
package, reviews it for architectural simplicity and naming, and writes a rename and
simplification table plus line-by-line comments. It posts to the PR only after you pick
one root-level comment or line-by-line comments. It never edits the code under review.

| Role | Model | Job |
| --- | --- | --- |
| Main session | any | Pulls, diagrams, verifies findings, and posts on your answer |
| `review-diff-lens` | Opus | Reviews the diff for simplicity or for naming |
| `map-repo`, `find-call-sites` | Haiku | Package boundaries and callers of renamed exports |

It uses two optional tools when they are installed and names any that are missing:
[Skema](https://github.com/semper-nova-tech/pallas-skema) (`skema-diagram` skill and the
`skema` CLI, 0.3.3 or newer) draws the diagrams, and Hunk (`cli-hunk` skill and the
`hunk` CLI) walks the diff and holds the inline comments in your live session. Without
them it draws plain-text diagrams and keeps the comments in its report. It never
installs either one without asking.

## Herdr

Start a quick change in its own worktree and pane:

```bash
plugins/pallas-quick/adapters/herdr/pallas-quick-herdr.sh start \
  --repo /path/to/repo \
  --branch fix-typeahead-count \
  --base develop \
  --request "Fix the typeahead count when filters are cleared" \
  --advisor opus
```

The script prints the agent name, pane, and worktree path. Remove the worktree with
`herdr worktree remove` after the PR merges.
