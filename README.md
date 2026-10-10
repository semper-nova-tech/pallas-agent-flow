# Lore Flow

Lore Flow is a portable, skills-only workflow plugin for turning a product
requirement into a sequenced set of implementation branches and reviews. It
does not ship a runtime, service, or project template. The workflow lives in
one canonical root `skills/` directory so Cursor and Claude Code execute the
same instructions.

Harness-specific agents are deliberately thin. They translate a harness's
agent, model, and tool conventions into calls to the canonical skills; they do
not duplicate workflow policy. This keeps behavior consistent while still
allowing each harness to use its native delegation and review features.

## Presets

Lore Flow offers three operating presets:

- **normal** favors short plans, a small number of agents, and focused reviews;
  use it for routine changes with known boundaries.
- **heavy** adds deeper decomposition, stricter dependency gates, and more
  review passes; use it for migrations, cross-system work, or high-risk changes.
- **simple** uses one Opus-led spec/recovery loop, Ponytail gates, and parallel
  Cursor builders; use it when independent technical specs can be implemented
  concurrently.

A preset is a starting policy, not a promise that a particular model or amount
of parallelism is available. Select the harness-qualified key from
`config/presets.json`, such as `cursor.simple`, `cursor.normal`, or
`claude.heavy`.

## Product spec mode

Lore Flow also provides a separate `product-spec` mode for turning an idea
or product change into an approved PRD before implementation planning. It is a
human-in-the-loop interview and review loop, not a build preset:

```text
idea or change → product context → focused interview → PRD review
             → human approval → product/prds/<feature-slug>.md
```

Invoke `/product-spec` (or ask the active harness to run Lore Flow's
product-spec mode) against a target repository. The mode reads and, when
missing, bootstraps this durable context:

```text
product/
├── CURRENT_PRODUCT_STATE.md
├── PERSONAS.md
├── GLOSSARY.md
└── prds/
    └── <feature-slug>.md
```

Existing product documents are evidence, not disposable input. The product
agent preserves them, identifies conflicts, and asks about unresolved product
choices. `CURRENT_PRODUCT_STATE.md` remains a record of current behavior; a
proposed change belongs in the PRD. After the PRD is explicitly approved, pass
its path to `/orchestrate-feature` when implementation is wanted. Product spec
mode never launches builders automatically.

## Compatibility

Lore Flow can operate against any repository opened by a current Cursor or
Claude Code installation, subject to these requirements:

- The target must be a Git repository because builders use branches and worktrees.
- The harness must support plugins, custom subagents, skills, and worktrees.
- At least one configured model candidate must be available for every required role.
- The user must have permission to create worktrees and, when requested, branches or PRs.
- Repository-specific setup, test commands, credentials, and coding-standard skills remain
  the target repository's responsibility.

Planning can run without a remote. Creating pull requests requires a configured remote and
the harness's normal Git hosting authentication.

## Install

Clone Lore Flow once, outside any target repository. Cursor and Claude Code both
read that same checkout. Cursor loads `.cursor-plugin/plugin.json`. Claude Code
loads `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`. Keep a
single `skills/` tree. Copying skills into a harness-specific folder, or into a
target repo, forks the workflow.

```bash
mkdir -p "$HOME/.cursor/plugins/local"
git clone git@github.com:jmarlett93/lore-flow.git "$HOME/.cursor/plugins/local/lore-flow"
ln -sfn "$HOME/.cursor/plugins/local/lore-flow" "$HOME/tools/lore-flow"
export LORE_FLOW_HOME="$HOME/.cursor/plugins/local/lore-flow"
```

The directory at `~/.cursor/plugins/local/lore-flow` has to be the Git checkout
itself. Cursor loads a local plugin only when that path is a real directory, or
a symlink whose target stays inside `~/.cursor/plugins/local`. A symlink from
`plugins/local/lore-flow` out to `~/tools/lore-flow` or `~/Projects/lore-flow`
is ignored, and the skills never appear. Point the convenience paths at the
checkout, as the `ln -sfn` above does.

On Windows, clone straight into
`%USERPROFILE%\.cursor\plugins\local\lore-flow`. A junction that leaves that
folder has the same problem as an outside symlink.

Reload the harness after the checkout is in place. Desktop: **Developer: Reload
Window**, then confirm Customize lists the `lore-flow` plugin, its skills, and
its agents. CLI: quit the current `agent` process and start a new one. A session
that is already running keeps the skill list it started with.

### Optional Herdr adapter

Herdr users can select `herdr` as the execution adapter. The adapter creates one
workspace for the run, then launches each Cursor worker in a real child pane and
waits for it to settle, while Lore Flow retains ownership of packets, worktrees,
reviews, and recovery. See [adapters/herdr/README.md](adapters/herdr/README.md).

### Cursor CLI, one session

To try a checkout without a persistent install:

```bash
cd /path/to/target-repository
agent --workspace "$PWD" --plugin-dir "$LORE_FLOW_HOME"
```

`--plugin-dir` applies to that process only. `~/.cursor/cli-config.json` and a
project `.cursor/cli.json` have no plugin-directory field. An alias that injects
`--plugin-dir` is a shell workaround, not Cursor configuration.

### Cursor account install

Register this repository as a user marketplace, then install the plugin. Adding
the marketplace indexes it. The skills stay unloaded until install.

```bash
agent plugin marketplace add git@github.com:jmarlett93/lore-flow.git
```

In a new interactive session, open `/plugins` and install `lore-flow` at **user**
scope so every workspace gets it. Project scope writes the install into that
repository only.

The CLI reads plugin installs from the workspace file
`<repo>/.cursor/settings.json` (the working directory), alongside user installs
stored on the Cursor account. A direct Git install looks like this:

```json
{
  "plugins": {
    "lore-flow": {
      "enabled": true,
      "gitUrl": "https://github.com/jmarlett93/lore-flow.git"
    }
  }
}
```

After the marketplace is registered, a marketplace reference is enough. The key
is `marketplace/plugin`:

```json
{
  "plugins": {
    "lore-flow/lore-flow": {
      "enabled": true
    }
  }
}
```

`~/.cursor/settings.json` is not the file the CLI consults for this. Putting
the block there does not import the skills.

### Claude Code

Load Lore Flow for one session from the target repository:

```bash
cd /path/to/target-repository
claude --plugin-dir "$LORE_FLOW_HOME"
```

Confirm it appears in `/plugin`. Plugin skills are namespaced, so the orchestration skill
is available as `/lore-flow:orchestrate-feature`.

For persistent installation, add this repository as a Claude Code marketplace and install
the plugin. Project scope records the installation in the target repository:

```bash
claude plugin marketplace add jmarlett93/lore-flow
claude plugin install lore-flow@lore-flow --scope project
```

User scope (`--scope user`) loads it in every Claude Code project. After a
release is published, update an existing installation with:

```bash
claude plugin update lore-flow@lore-flow
```

For local development, continue to use `--plugin-dir`; it loads the checked-out files
directly without marketplace caching.

### Update or remove

Update a cloned installation with the repository's normal Git workflow, then
reload the harness. Remove a Cursor local installation by deleting the checkout
at `~/.cursor/plugins/local/lore-flow` (and any convenience symlink that points
at it). Session-only `--plugin-dir` loading leaves no installation in the target
repository. Remove an account marketplace with
`agent plugin marketplace remove lore-flow`, then uninstall the plugin from
`/plugins`.

## How agents import these skills

Future agents should load Lore Flow as a plugin. The target repository's
`.agents/skills/`, `.cursor/skills/`, and `~/.cursor/skills/` are a different
catalog (coding standards and personal skills). Copying `skills/*/SKILL.md`
into those folders does not install Lore Flow, and it will drift from this
checkout.

Check the session's skill list before inventing an install. These ten skills
ship in `skills/`:

| Skill | Role |
| --- | --- |
| `product-spec` | Interview and write an approved PRD |
| `review-prd` | Define the current-to-requested behavior frontier |
| `orchestrate-feature` | Run or resume a full Lore Flow delivery |
| `discover-stack` | Evidence-backed stack discovery for one area |
| `plan-requirements` | Turn an accepted PRD into testable technical requirements |
| `ponytail` | Adversarial scope and requirement review |
| `sequence-prs` | Split approved requirements into a PR sequence |
| `build-pr` | Implement one sequenced PR in its worktree |
| `realign-run` | Apply an explicit human review and recompute impact |
| `final-report` | Evidence-backed completion report |

Cursor shows them as `/product-spec` or `/lore-flow:product-spec`, depending on
whether the plugin namespace is prefixed. Claude Code always namespaces them:
`/lore-flow:orchestrate-feature`. Custom agents live in `agents/cursor/` and
`agents/claude/`; they call these skills and do not carry a second copy of the
policy.

Import order when the skills are missing:

1. If `~/.cursor/plugins/local/lore-flow/.cursor-plugin/plugin.json` exists and
   that path is a real directory, start a new agent session or reload the
   window. The running session will not gain the skills.
2. If that path is a symlink to somewhere else, replace it with the checkout
   described in Install. Reloading will not fix an outside symlink.
3. Otherwise register the marketplace and install at user scope, or pass
   `--plugin-dir` for a single CLI session. Marketplace add alone leaves the
   skills unloaded.
4. For one Cursor repository, write the `plugins` block into that repo's
   `.cursor/settings.json`, then start a new session from that repo.

A session whose skills are only the target repo's `.agents/skills` plus
`~/.cursor/skills` has not loaded this plugin. Read the skill from
`$LORE_FLOW_HOME/skills/<name>/SKILL.md` only as a fallback while fixing the
install. The next session should show the slash command.

## Verify the installation

Before the first build run:

1. Confirm all Lore Flow skills and harness agents are visible.
2. Confirm the selected key exists in `config/presets.json`.
3. Confirm the configured model candidates are available to the account.
4. Confirm the target repository is a clean, usable Git checkout.
5. Run planning first and verify that it pauses at the technical-spec review.

## Invoke a run

Invoke the Lore Flow orchestration skill with:

1. a PRD, issue, or concise change description;
2. the target repository and base branch;
3. a harness-qualified preset such as `cursor.simple`, `cursor.normal`, or
   `claude.heavy`; and
4. any required reviewers, model preferences, or repository constraints.

For Cursor, invoke `/orchestrate-feature` or ask:

> Run Lore Flow with `cursor.simple` for this PRD against `main`.

For Claude Code, invoke:

```text
/lore-flow:orchestrate-feature Run with claude.normal for this PRD against main.
```

The orchestrator decomposes the request, records dependencies, and dispatches
only work whose prerequisites are satisfied.

## Published review pack

Reviewers should not open `.lore-flow/`. After planning, the workflow mints a
committed pack, by default:

```text
docs/features/<feature-slug>/
├── README.md                      # systems summary
├── technical-spec.md              # full PRD-derived behaviors
├── architecture-overview.md       # end-state models, contracts, diagrams
├── sequence.md                    # PR order and dependency DAG
└── prs/
    └── <nn>-<domain>-<purpose>.md # this PR's slice, with pseudo-code or nominal flow
```

Each PR note links to facets of the architecture overview. Keep `.lore-flow/` in
the target repository `.gitignore`; copy [templates/gitignore](templates/gitignore) if
needed.

## Run artifacts

Each run writes recovery evidence under the target repository. Gitignore this tree:

```text
.lore-flow/runs/<run-id>/
├── run.md
├── artifact-index.md
├── prd-reviews/<feature-slug>.md
├── discovery/
├── guidance/<packet-id>.md
├── architecture/
├── decisions/
├── human-reviews/
├── realignments/
├── pull-requests/
└── reports/<feature-slug>-final.md
```

`run.md` records status, phase, constraints, decisions, and blockers.
`artifact-index.md` links published files and run evidence. Preserve superseded
decisions instead of silently overwriting them; recovery must not depend on replaying
chat text.

Artifacts and narration lead with readable names and plain-language purpose. Internal IDs
and versions remain index metadata for exact traceability. For example:

- Before: `F-002 invalidates ART-007 v3; approve D-F1-R2.`
- After: `Hosted order events (F-002) changed the runtime assumption. The Order service
  topology draft can no longer be trusted and needs architecture review again.`

Readable filenames use stable purpose slugs, such as
`docs/features/hosted-order-events/technical-spec.md` and
`docs/features/hosted-order-events/prs/02-backend-publish-order-events.md`. Run-folder
names may remain as evidence aliases.

### Architecture documentation

The committed architecture overview is the end-state document people read: simple object
models, contracts, and justified diagrams. Run-scoped `architecture/` files are
versioned evidence only.

If the repository already has architecture or ADR conventions, builders still update
those domain docs in the owning PR. Otherwise they may also write
`docs/architecture/` and `docs/adr/`. Cross-cutting API docs default to the
contract-producing backend PR.

Diagrams appear only when they materially clarify relationships. Proposed diagrams land
in `architecture-overview.md` before requirements approval. The PR DAG lands in
`sequence.md` before sequence approval. Each PR note may add a small nominal flow for
its slice.

## Human approval and realignment

Every run pauses at these approval checkpoints before builds:

1. Requirements approval, after Ponytail accepts the technical requirements.
2. PR sequence approval, after the sequence and PR notes are generated.
3. Per-PR approval, before each PR build. This is on by default (`each-pr: true`);
   set it to `false` in the preset to skip.

At each pause, status is `awaiting-human-review`. The reviewer receives the published
pack first, then exact versions. Lore Flow records the reviewer's
identity, decision, timestamp, comments, and reviewed versions, then resumes
only on explicit approval. Per-PR approval supplements, and never replaces, the
requirements and sequence checkpoints.

Reviewers may edit names, requirements, design, scope, or sequence and request
changes. Invoke `realign-run` with the run ID and review record. It preserves
accepted history, records rename aliases, computes transitive impact, and
supersedes only affected downstream artifacts. Unaffected accepted work stays
valid, and the run returns to the earliest impacted approval checkpoint.

When builds or worktrees already exist, realignment proposes `keep`, `rebase`,
`replace`, or `cancel` for each affected unit. It does not mutate or discard
that work until a human explicitly approves the action. To resume, invoke the
orchestrator with the run ID and an approval naming the current artifact
versions; silence or edited files alone are never approval.

Generated run artifacts should normally remain uncommitted. A target repository
may ignore them or archive selected artifacts according to its own policy.

## Branch and worktree lifecycle

Each implementation unit gets its own branch and worktree. A worker may change
only that unit's declared scope. It commits locally when the harness workflow
requires a handoff, then records the commit and verification evidence in the
unit artifact.

The orchestrator keeps the base checkout stable, integrates units in dependency
order, and never reuses a dirty worktree. Successful worktrees can be removed
after their commits are safely integrated. Failed or interrupted worktrees and
branches are preserved until recovery is complete; cleanup must not discard
uncommitted work.

## Sequencing rules

Dependencies describe what must be usable before another unit can complete,
not merely which section appeared first in the PRD.

- Prefer backend or contract providers before consumers.
- Frontend may come first only when it is intentionally a no-op or can operate
  against an existing stable contract; record the exception explicitly.
- Existing, non-blocking infrastructure adjustments may land late.
- Net-new infrastructure that blocks build, deploy, test, or runtime must land
  before dependent application work.
- Contract migrations use an expand/migrate/contract sequence: add a compatible
  provider, migrate every consumer, then remove the old contract.
- A failed required review blocks integration and downstream dependents. Fix
  the same unit and rerun that reviewer rather than treating review as advisory.

Independent units may run in parallel. A unit becomes ready only when every
declared prerequisite has reached its required completion or review state.

## Context management

Treat run artifacts as the source of truth. Give workers the smallest useful
context: the unit brief, relevant files, dependency outputs, repository
standards, and acceptance checks. Keep broad PRD interpretation and graph
management in the orchestrator. Summaries should point to artifacts and commits
instead of copying long transcripts between agents.

When context becomes crowded, start a fresh worker from the recorded unit state
rather than relying on conversational memory.

## Resume and recovery

To resume, invoke the orchestration skill with the run ID. The orchestrator
reads `run.md` and `artifact-index.md`, verifies indexed artifacts, branches,
worktrees, commits, and reviews against the repository, then continues only
ready work.

If recorded state disagrees with Git or the filesystem, preserve both, mark the
unit blocked, and require reconciliation. Do not silently recreate branches,
discard worktrees, skip a failed review, or infer success from a previous chat.

## Models and fallbacks

Model names are preferences interpreted by the active harness. Availability can
vary by account, policy, region, and harness release. Presets may list ordered
model candidates, but the harness must resolve the selected model explicitly
and record it. If the preset, adapter, required role, or permitted model is
unavailable, stop and report the missing capability; never invent a fallback or
silently weaken a required review.

## Repository coding standards

Lore Flow supplies workflow skills, not target-specific coding policy.
Target repositories should expose their coding standards as discoverable skills
in the locations supported by each harness. A repository can keep standards in
one canonical directory and link each skill into `.cursor/skills/` and
`.claude/skills/`; there is no need to maintain divergent copies. Keep those
skills narrow and actionable—for example, TypeScript conventions, test
commands, accessibility checks, database migration rules, or release
requirements—and reference them from repository agent guidance when necessary.

The orchestrator creates a small guidance manifest for each implementation packet.
It records applicable `AGENTS.md`, `.cursor/rules/`, and `.agents/skills/` paths,
reasons, statuses, and content hashes without copying their contents. Workers read
the exact manifest before editing and record guidance used or explicitly skipped in
the build report. Repository instructions override generic workflow examples when
they do not violate a run's explicit safety gates.
