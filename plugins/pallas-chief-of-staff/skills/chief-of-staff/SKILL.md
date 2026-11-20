---
name: chief-of-staff
description: Executive brief of everything in flight on this machine: registered repos, git and Herdr worktrees, running agents, pull requests, the product roadmap, and Linear. Registers the machine once, remembers its sources and tools, pulls only what changed since the last brief, writes the brief, and opens it in glow in a new Herdr tab. Can watch overnight and brief in the morning. Use for "what's going on", "catch me up", "morning brief", "register this machine", "add a source", or "watch overnight".
---

# Chief of staff

Read everything, change nothing. Decide what deserves the human's attention first and
say the next action for it. Do not implement, merge, answer a blocked agent, edit a
roadmap, or write to Linear. The only files this skill writes live in its home.

`project-manager` reports one repository's product portfolio. This skill sits above
it: one machine, every registered source, one brief.

## Home

Per machine, at `${PALLAS_CHIEF_HOME:-${XDG_CONFIG_HOME:-~/.config}/pallas-chief-of-staff}`.
Another machine registers separately and keeps its own registry.

| File | Role |
| --- | --- |
| `registry.json` | Machine id, `script_path`, sources, `cursor.last_brief_at`, `watch` pane, agent, brief time |
| `tools.json` | Tool detection, refreshed every brief |
| `snapshots/<utc>.json` | One pull. The collector writes one per interval overnight |
| `reports/<date>-<time>.md` | Briefs. Never overwritten |

## Script

`scripts/chief.sh` in this plugin does the plumbing. Find it at
`${CLAUDE_PLUGIN_ROOT}/scripts/chief.sh` in Claude Code, else this plugin's install
directory in Cursor, else the `script_path` recorded in
`registry.json`, else `$PALLAS_AGENT_FLOW_HOME/plugins/pallas-chief-of-staff/scripts/chief.sh`.
Every subcommand prints JSON except `report new`, which prints a path.

| Subcommand | Does |
| --- | --- |
| `init` | Create the home and registry; record `script_path` |
| `detect` | Write `tools.json` |
| `source add --kind git\|worktrees\|roadmap\|linear (--path P \| --spec S)` | Register a source; `list`, `remove ID` |
| `pull [--since ISO] [--source ID] [--quiet]` | Harvest every source into one snapshot. `--quiet` prints counts and the path only |
| `snapshot latest` / `snapshot since ISO` | Snapshot paths for the timeline |
| `cursor set [ISO]` | Record when the last brief was written |
| `report new` / `report open PATH` | New brief path; open a brief in glow in a new Herdr tab, or print a fallback |
| `watch start [--interval S] [--brief-at HH:MM] [--agent NAME] [--kind KIND] [--plugin-dir DIR]` / `watch stop` | Collector pane that pulls on an interval and fires the brief at a time, and its shutdown |
| `fire-brief [--agent NAME] [--kind KIND] [--prompt TEXT]` | Prompt the live agent in Herdr to write the brief, or start one of the same kind. The collector calls it |

## Modes

| Ask | Mode |
| --- | --- |
| First run on a machine, "register", no `registry.json` | Register |
| Anything else, or no mode named | Brief |
| "watch", "overnight", "monitor", "in the morning" | Watch |
| "add", "remove", "sources" | Sources: run the `source` subcommand and show `source list` |

## Tools

Run `detect` at the start of every brief. A tool that is present changes what the brief
can say. A tool that is missing is named once in the Sources section, never worked around.

| Tool | Detected by | Unlocks | Without it |
| --- | --- | --- | --- |
| Herdr | `herdr` on `PATH`, `HERDR_ENV=1`, and the `cli-herdr` skill registered | Agent states, Herdr worktrees, the brief in a new tab, the watch pane, a notification | Git worktrees only; print the brief path and `glow -p` hint |
| Pallas Agent Flow | plugin installed | Delegate every `roadmap` source to its `project-manager` and read active `.pallas-agent-flow/runs/*/run.md` status lines | Read `roadmap.md` and `in-progress.md` from the snapshot |
| Pallas Quick | plugin installed | Recognize quick-change panes by their agent title and branch | Nothing |
| Skema | `skema` binary and the `skema-diagram` skill | On request, a status map SVG beside the brief, opened in the Editor pane | Nothing |
| `gh` | authenticated | Open PRs, review requests, check results | Branches only |
| Linear | Linear MCP tools or the `linear-api` skill in this session | Issues assigned to me, my notifications | `linear` sources marked not pulled |
| `glow` | on `PATH` | Rendered brief | Print the path |

## Sources

Each source is optional. A source the registry does not name is not pulled.

| Kind | Add | Pull gives | Delta since cursor |
| --- | --- | --- | --- |
| `git` | `--path <repo>` | Default branch, remote branches with ahead/behind, commits, worktrees with dirty counts, open PRs with checks and review requests | Commits and PR updates after `last_brief_at` |
| `worktrees` | `--path <repo>` | Git worktrees, and Herdr worktrees for that repo | Compared against the previous snapshot |
| `roadmap` | `--path <repo>/product/roadmap.md` | Now, Next, Later slugs; `in-progress.md` harvest line; ledger row count; whether to delegate | File mtime after `last_brief_at` |
| `linear` | `--spec me` or `--spec <TEAM-KEY,...>` | Pulled in-session, not by the script | Issues updated after `last_brief_at` |

Herdr agents are pulled on every snapshot whenever Herdr is available. They are not a
source to add.

## Register

1. Run `init`, then `detect`.
2. Propose sources without adding them. Candidates: the current repository as `git` and
   `worktrees`; the repository root of every Herdr agent and workspace cwd
   (`git rev-parse --show-toplevel` on each); `product/roadmap.md` in each of those as
   `roadmap`; `linear --spec me` when Linear tools are present.
3. Ask the human to confirm the list in one message. Add what they accept. Add nothing
   they did not accept.
4. Show `source list` and the detected tools in one table. Say the home path, and that
   this registry belongs to this machine.

## Brief

Everything the main session reads is a summary. Raw snapshot JSON, `gh` output, and git
logs stay inside the scouts.

1. Run `detect` and `pull --quiet`. A source with `error` set goes to Sources as failed,
   with its error. Do not retry in a loop.
2. Run `snapshot since <last_brief_at>`. More than one path means the watch pane has
   been collecting. Hand the whole list to the scouts so they can report a timeline.
3. Start one `source-scout` per source, plus one for `herdr_agents`, in parallel. Give
   each the snapshot path or paths and its source id. Each returns at most one screen.
4. Pull Linear in this session when a `linear` source exists and Linear tools are
   present: issues assigned to me that are not done, issues I created or am subscribed
   to that changed since the cursor, and unread notifications. Cap at 30 items. Read
   only. Note the ones due today, overdue, or moved to a state that waits on me.
5. For each `roadmap` source whose snapshot says `delegate`, run the
   `pallas-agent-flow:project-manager` agent in that repository and keep only its
   spin-up summary. Tell it not to commit. Without the delegation, use the roadmap
   fields in the snapshot.
6. Rank with the table below, write the brief from `references/brief.md` to the path
   `report new` prints, then run `report open <path>`.
7. Run `cursor set`.
8. In chat, give the headline and where the brief opened: the tab id, or the path and
   the `glow -p` hint when it did not open. Do not paste the brief into chat.

Budget: the brief is under 120 lines. Each section lists items the human would act
on or want to know changed, not inventories. Counts replace lists when a list would
exceed eight items, with the top three named.

## Needs you

Order items in this section by the first rule they match. Each line names the thing,
the evidence (pane id, PR url, issue key, branch), and the one next action.

| Rank | Signal |
| --- | --- |
| 1 | Herdr agent `blocked`: an approval or question is waiting. Quote its question in one line. Never answer it |
| 2 | Open PR with review requested from me |
| 3 | Failing or errored checks on a PR I authored |
| 4 | Linear issue assigned to me that is overdue, due today, or moved to a state waiting on me |
| 5 | Roadmap slug `ready` (a PRD approved here but not on the default branch) or `blocked` |
| 6 | Dirty worktree with no agent in it and no commit for 48 hours |

`done` agents go to Since last brief, with their last line of output. `working` agents
go to In flight. A source that failed goes to Sources, never silently.

## Watch

For "watch overnight" or "brief me in the morning":

1. Settle the time. "Brief me at 7" means `--brief-at 07:00`. "Fifteen minutes before I
   sit down at 7" means `06:45`. No time given: ask once, or default to `06:45`.
2. Run `watch start --interval 900 --brief-at HH:MM --agent chief --plugin-dir <plugin root>`.
   This renames the calling agent to `chief`, records its Herdr kind (`claude`,
   `cursor`, `codex`, and so on) so a replacement runs on the same harness, opens a
   Herdr tab running the collector loop, and records all of it in the registry. The
   collector uses no model. At the brief time it runs one last pull, then fires the
   brief from outside the session:
   - a live `chief` agent that is `idle` or `done` gets the prompt
     `/pallas-chief-of-staff:chief-of-staff brief`;
   - a `working` agent is waited for, up to ten minutes, then prompted;
   - a `blocked` agent is left alone and a Herdr notification says the brief was not sent;
   - no live agent means a new tab, `herdr agent start chief --kind <recorded kind>`
     with `--plugin-dir`, then the prompt. Both the Claude Code and Cursor CLIs take
     `--plugin-dir`.
   When the harness shows this skill without the plugin prefix, pass
   `--prompt "/chief-of-staff brief"` so the prompt matches what it lists.
   A brief time missed because the machine slept fires once on wake, then moves to
   the next day.
3. Tell the human the two things the script cannot do: keep the Mac awake and keep
   Herdr running. Suggest `caffeinate -s` in any pane, or a `pmset repeat wakeorpoweron`
   schedule a few minutes before the brief time.
4. Outside Herdr, `watch start` refuses. Fall back to the harness's own scheduler when
   it has one (Claude Code: `CronCreate`, one-shot at the brief time, prompt
   `/pallas-chief-of-staff:chief-of-staff brief`) and say its limits: the job lives
   only in this session, fires only while the session is idle, and a recurring job
   expires after seven days. A harness with no scheduler gets the collector only, and
   the human asks for the brief in the morning.
5. Only when live alerts are asked for, and only when the harness has a background
   monitor (Claude Code: `Monitor`): arm it with a loop that runs `pull --quiet` every
   five minutes and prints one line when the `blocked` count rises or a PR check turns
   failing. Cover failure too: print a line when `pull` itself fails. Set the maximum
   timeout and re-arm on expiry. On an event, show a Herdr notification, and a push
   notification when the harness offers one.
6. The morning brief reads the overnight snapshots through the scouts and fills the
   Timeline section. Run `watch stop` after it unless the human asked to keep watching;
   a watch left running fires again at the same time the next day.

## Rules

- Read-only on every source: no checkout, fetch is the only network write to a clone,
  no push, no PR comment, no Linear write, no roadmap edit, no pane closed except the
  watch pane this skill opened.
- Never send input to another agent. Report what it is waiting for.
- Say when a tool or source was unavailable. Silence is not success.
- Dates in the brief are absolute, in local time, with the UTC pull time in Sources.
- Never read a secret or print a token. `gh auth status` output stays in the script.
