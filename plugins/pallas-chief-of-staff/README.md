# Pallas Chief of Staff

One brief per machine covering everything in flight: registered repositories, git and
Herdr worktrees, running agents, pull requests, the product roadmap, and Linear. The
skill registers the machine once, remembers its sources and tools, pulls what changed
since the last brief, and opens the brief in `glow` in a new Herdr tab. It can collect
overnight and brief in the morning.

`project-manager` in Pallas Agent Flow reports one repository's product portfolio. This
plugin sits above it and delegates to it when it is installed.

| Role | Model | Job |
| --- | --- | --- |
| Main session | any harness, any model | Register, rank, write the brief |
| `source-scout` | Haiku | Read one source out of a snapshot and return one screen |
| `pallas-agent-flow:project-manager` | as installed | Roadmap stage and next step per repository, when that plugin is present |

## Install

Install `pallas-chief-of-staff` from this repository's marketplace at user scope. Cursor
reads `.cursor-plugin/marketplace.json`; Claude Code reads `.claude-plugin/marketplace.json`.

```bash
claude plugin marketplace add jmarlett93/pallas-agent-flow
claude plugin install pallas-chief-of-staff@pallas-agent-flow --scope user
```

In Cursor, add the same marketplace with `agent plugin marketplace add`, then install
`pallas-chief-of-staff` at user scope from `/plugins`. The slash command is
`/pallas-chief-of-staff:chief-of-staff` in Claude Code and either that or
`/chief-of-staff` in Cursor, depending on whether the namespace is shown.

Optional tools, each detected on every brief: `herdr` with `HERDR_ENV=1`, the
`pallas-agent-flow` and `pallas-quick` plugins, `skema`, an authenticated `gh`, the
Linear MCP server or `linear-api` skill, and `glow`. `jq` is required.

## Use

```text
/pallas-chief-of-staff:chief-of-staff register
/pallas-chief-of-staff:chief-of-staff
/pallas-chief-of-staff:chief-of-staff watch overnight, brief me at 7
/pallas-chief-of-staff:chief-of-staff add ~/projects/web as a source
```

The first run on a machine registers it: the skill detects tools, proposes sources from
the current repository and the running Herdr workspaces, and adds the ones you accept.
Every later run is a brief. Everything lives under
`~/.config/pallas-chief-of-staff/` (override with `PALLAS_CHIEF_HOME`).

## Sources

| Kind | Example | Pulls |
| --- | --- | --- |
| `git` | `--path ~/projects/web` | Branches, commits since the last brief, worktrees, open PRs with checks |
| `worktrees` | `--path ~/projects/web` | Git worktrees and Herdr worktrees for that repository |
| `roadmap` | `--path ~/projects/web/product/roadmap.md` | Now, Next, Later slugs; delegated to `project-manager` when available |
| `linear` | `--spec me` | Issues assigned to you and notifications, pulled in-session |

Herdr agents are included on every pull when Herdr is available.

## Overnight

```text
/pallas-chief-of-staff:chief-of-staff watch overnight, brief me at 6:45
```

`watch` renames the current agent `chief`, records which harness it is (Claude Code,
Cursor, Codex, or any other kind Herdr recognizes), opens a Herdr tab running
`chief.sh collect`, and records the brief time. The collector pulls every 15 minutes
with no model. At the brief time it pulls once more and prompts the `chief` agent with
the brief command from outside the session, so the brief does not depend on an
in-session timer. If no agent is alive it starts one of the same kind in a new tab with
this plugin loaded through `--plugin-dir`, which both the Claude Code and Cursor CLIs
accept. A blocked agent is left alone and a notification says so. A time missed while
the Mac slept fires once on wake.

The brief adds a Timeline section from the overnight snapshots: agents that went
blocked or finished, PRs opened or merged, checks that failed.

The script cannot keep the machine awake. Run `caffeinate -s` in a pane, or schedule
`sudo pmset repeat wakeorpoweron MTWRF 06:40:00`.

## Script

`scripts/chief.sh` does the plumbing and prints JSON. Run `scripts/check.sh` after
changing it; it uses a fake `herdr` and `gh`.

```bash
scripts/chief.sh init
scripts/chief.sh detect
scripts/chief.sh source add --kind git --path ~/projects/web
scripts/chief.sh pull --quiet
scripts/chief.sh watch start --brief-at 06:45 --plugin-dir "$PWD"
scripts/chief.sh report open ~/.config/pallas-chief-of-staff/reports/2026-11-19-0657.md
```

The script never checks out, pushes, comments, writes to Linear, or edits a roadmap.
`git fetch --prune` is its only network write to a clone.
