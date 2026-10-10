---
name: orchestrate-feature
description: Runs or resumes Lore Flow through technical specs, Ponytail review, parallel builds, targeted recovery, and reporting.
---

# Orchestrate Feature

Run Lore Flow without assuming a specific agent harness. Delegate by capability,
persist artifacts in the target repository, and keep the parent context small.

## Inputs

Require:

- target repository path
- PRD path or authoritative requirement source
- selected preset name

Accept optional constraints: issue or branch references, excluded paths, required checks,
PR policy, deployment environments, required reviewers, extra per-PR approval policy,
user decisions already made, and an execution adapter (`native` or `herdr`).

Resolve the named preset once with
`jq --arg p NAME '.presets[$p]' config/presets.json` from the Lore Flow installation;
do not page through the file. Record its harness, gates, and role/model mappings in
`run.md` and read them from there afterwards. Treat preset values as configuration,
not workflow semantics. If the preset, harness adapter, or required role is unavailable,
stop with a precise missing-input report; never silently substitute a harness or model.
If the preset name is missing, ask for it in the same turn with the available names.

## Run setup

Create a unique `run-id` and use this artifact root in the target repository:

`.lore-flow/runs/<run-id>/`

Initialize the run and artifact index according to
[run-schema.md](references/run-schema.md). Read
[context-packets.md](references/context-packets.md),
[diagram-policy.md](references/diagram-policy.md),
[human-readable-output.md](references/human-readable-output.md), and
[published-docs.md](references/published-docs.md) before delegating.
Include those policies and relevant assignments in every packet.

`.lore-flow/` is run machinery. If the target repository has no ignore rule for it,
add the template at `templates/gitignore`. Human approval uses the published pack under
`docs/features/<feature-slug>/`, not the run folder.

The parent retains only:

- current phase, decisions, blockers, and artifact index
- short summaries with paths to full evidence
- the bounded packet needed for the next delegation

Never forward transcripts, raw agent conversations, or unbounded command output.

Only the orchestrator talks to the human. Workers never ask for approval or decisions;
they finish with status `complete`, `clarification-required`, or `blocked` and put
decision requests in their return packet. The orchestrator marks an artifact
`accepted` in the index; only a human `approves` a checkpoint.

## Workflow

### 1. Create technical specs

The orchestrator invokes `review-prd` and only the necessary `discover-stack`
workers. Frontend, backend, and infrastructure discovery run concurrently when they
touch independent areas. Then `plan-requirements` emits one technical-spec packet per
independent implementation unit.

Skip discovery workers for a greenfield repository: when `git ls-files` lists no
application source, build, or CI files (only docs, licenses, and ignore files), write
`discovery-index.md` yourself with one line per area citing that file list and the
default `docs/features/<feature-slug>/` doc home.

Each packet names the requirement frontier, owned files, contracts, side effects,
dependencies, acceptance checks, and the smallest implementation that satisfies the
requirement. Before publishing a packet, create its guidance manifest at
`.lore-flow/runs/<run-id>/guidance/<packet-id>.md`. Inspect the target repository's
`AGENTS.md`, applicable `.cursor/rules/`, `.agents/skills/`, and any nested instruction
files. Record only applicable paths, why they apply, their content hashes, and
`required` / `recommended` / `not-applicable` status; do not copy their contents.
Persist the requirements, architecture overview, guidance manifests, packet index, and
versions in the run artifacts. The packet dependency graph is the execution plan.

If the `herdr` adapter is selected, create one Herdr workspace for the run using
`adapters/herdr/lore-flow-herdr.sh workspace`. Record the returned workspace, tab, and
root pane IDs in the run artifact. Use the adapter's `worker` command for every
delegated role, not only builders; see [adapters/herdr/README.md](../../adapters/herdr/README.md).

### 2. Review the specs

Invoke `ponytail` against the complete technical-spec set before any build. It challenges
YAGNI, unnecessary abstractions, speculative infrastructure, scope drift, missing
validation, and missing tests. The orchestrator repairs rejected specs and reruns
the review until the set is accepted or explicitly blocked.

Pause once for human approval of the Ponytail-approved technical-spec version. Do not
start builders until that exact version is approved. The `cursor.simple` preset disables
the separate PR-sequence and per-PR approval gates.

### 3. Build and review in parallel

Dispatch one `build-pr` worker per ready packet in a dedicated git worktree. Use only
the packet, relevant repository instructions, dependency outputs, and approved
artifacts. Independent packets run concurrently; dependent packets wait for their
declared prerequisites.

With the `herdr` adapter, run one adapter `worker` per ready packet with the packet's
worktree as `--cwd` and the selected builder model; background independent workers
with `&` and join them with `wait`. A non-zero exit or `blocked` status is a recovery
event and never a successful build. Close a worker's pane with the adapter's `close`
after its output is accepted. Native Cursor delegation remains the default when no
adapter is selected.

When a builder finishes, immediately invoke `ponytail` against that unit's diff and
validation evidence. The review looks for unnecessary code, hidden coupling, contract
drift, weak tests, accidental scope, and mismatch with the approved packet. Send only
rejected units to repair and rerun their checks and review. Accepted units remain
complete while other units continue.

### 4. Recover and report

The orchestrator reads `run.md`, `artifact-index.md`, packet versions, worktree
state, commits, checks, and review findings. For a failure, preserve the failed
worktree and evidence, then retry or repair only that unit. Do not restart accepted
units.

If a repair changes a contract, mark dependent packets stale, regenerate only those
packets, and return them to Ponytail spec review. If state disagrees with Git or the
filesystem, preserve both views and block for reconciliation. Never infer success from
chat history.

Invoke `final-report` after all reachable units finish. Report each unit, checks,
Ponytail findings, unresolved risks, deferred work, artifact paths, and blocked
recovery actions.

## Approval and execution rules

- No build before explicit human approval of the Ponytail-approved technical-spec set.
- No resume from a failed or awaiting-review state without reading persisted artifacts.
- No build from a stale, invalidated, or superseded packet.
- No dependent unit before its blocking prerequisite is ready.
- No cleanup of failed worktrees or branches until recovery is complete.
- No claim without evidence or an explicit `unknown`.
- No context packet that exceeds the bounds in the context contract.
- No final success claim when required checks, reviews, or artifacts are missing.

When review is pending, preserve completed artifacts and report the exact action needed.
When blocked, report the smallest decision or reconciliation needed. Never silently
realign or discard work.
