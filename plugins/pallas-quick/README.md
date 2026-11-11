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
