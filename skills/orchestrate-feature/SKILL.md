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
user decisions already made, a published-pack mode override, and an execution adapter
(`native` or `herdr`).

Resolve the named preset once with
`jq --arg p NAME '.presets[$p]' config/presets.json` from the Lore Flow installation;
do not page through the file. Record its harness, approval checkpoints, published-pack
mode, and role/model mappings in `run.md` and read them from there afterwards. Treat
preset values as configuration, not workflow semantics. If the preset, harness adapter,
or required role is unavailable, stop with a precise missing-input report; never silently
substitute a harness or model. If the preset name is missing, ask for it in the same
turn with the available names.

## Run setup

Read [run-schema.md](references/run-schema.md),
[context-packets.md](references/context-packets.md),
[diagram-policy.md](references/diagram-policy.md),
[human-readable-output.md](references/human-readable-output.md),
[published-docs.md](references/published-docs.md), and the plugin
[glossary](../../docs/glossary.md) before delegating. Include those policies and relevant
assignments in every packet.

At intake, in this order:

1. Derive the feature slug and the run-id `<yyyy-mm-dd>-<ticket>-<feature-slug>`.
2. Create the run root `.lore-flow/runs/<run-id>/` and record its absolute path.
3. Write `run.md` with the Names block, an empty Where things stand table, and the
   resolved preset.
4. Create `aliases.md` with the Names block as its first rows.
5. Create the feature glossary from `templates/feature/glossary.md` at the published
   pack path, or at the run root when the published-pack mode is `none`.
6. Write `artifact-index.md` with rows for the three files above.

`.lore-flow/` is run machinery. If the target repository has no ignore rule for it,
add the template at `templates/gitignore`. Human approval uses the published pack, not
the run folder.

The parent retains only:

- current phase, decisions, blockers, Where things stand, and artifact index
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
touch independent areas. Discovery seeds the glossary with `existing` rows; PRD review
adds `new` rows with meanings. Then `plan-requirements` emits one named requirement set
as the published technical spec, architecture overview, and glossary surfaces. Planning
writes no packets; packets come only from `sequence-prs`.

Skip discovery workers for a greenfield repository: when `git ls-files` lists no
application source, build, or CI files (only docs, licenses, and ignore files), write
`discovery-index.md` yourself with one line per area citing that file list and the
default `docs/features/<feature-slug>/` doc home.

Persist the requirements, architecture overview, glossary, and versions in the run
artifacts. Run the consistency check before requesting approval.

If the `herdr` adapter is selected, create one Herdr workspace for the run using
`adapters/herdr/lore-flow-herdr.sh workspace`. Record the returned workspace, tab, and
root pane IDs in the run artifact. Use the adapter's `worker` command for every
delegated role, not only builders; see [adapters/herdr/README.md](../../adapters/herdr/README.md).

### 2. Review the specs

Invoke `ponytail` in `pre-build` mode against the complete technical-spec set and
glossary before any sequencing. It challenges YAGNI, unnecessary abstractions,
speculative infrastructure, scope drift, missing validation, missing tests, naming, and
every item marked `assumed`. Reject a review file that lacks the template headings. The
orchestrator repairs rejected specs and reruns the review until the set is accepted or
explicitly blocked. A re-review opens with what changed since the previous review.

Pause once for human approval of the Ponytail-approved technical-spec version. Do not
sequence or build until that exact version is approved. The `cursor.simple` preset
disables the separate PR-sequence and per-PR approval checkpoints.

### 3. Sequence

Invoke `sequence-prs` against the approved spec version. It mints the published
sequence, one PR note per PR, one guidance manifest per PR, and one build packet per
PR, each carrying the glossary rows the PR owns. Lint every packet against the build
packet field list before review: a packet missing a field, mixing areas, naming a
dependency discovery did not observe, or exporting a symbol with no glossary row is
returned to the sequencer. Pause for sequence approval.

### 4. Build and review in parallel

Dispatch one `build-pr` worker per ready packet in a dedicated git worktree. Dispatch
only when the packet version has an `accepted` Ponytail row and the human record that
approves that exact version, and the consistency check passed. Use only the packet,
relevant repository instructions, dependency outputs, and approved artifacts.
Independent packets run concurrently; dependent packets wait for their declared
prerequisites. Update Where things stand at every state change.

With the `herdr` adapter, run one adapter `worker` per ready packet with the packet's
worktree as `--cwd` and the selected builder model; background independent workers
with `&` and join them with `wait`. A non-zero exit or `blocked` status is a recovery
event and never a successful build. Close a worker's pane with the adapter's `close`
after its output is accepted. Native delegation remains the default when no adapter is
selected.

When a builder finishes, immediately invoke `ponytail` in `post-build` mode against that
unit's diff and validation evidence. The review looks for unnecessary code, hidden
coupling, contract drift, exports without glossary rows, weak tests, accidental scope,
and mismatch with the approved packet. Send only rejected units to repair and rerun
their checks and review. Accepted units remain complete while other units continue. No
PR is opened without an accepted post-build review file.

### 5. Realign when a human changes course

Route to `realign-run`, and set status `realigning`, whenever:

- a checkpoint reply is anything other than `approved`, `changes-requested`, or
  `rejected`, including an approval that carries answers which change a contract, path,
  owner, dependency, protocol, or term meaning;
- an instruction during a build changes the unit's contract, scope, or names; pause the
  builder first and restart it only from the new packet version;
- a review commit renames or removes an exported symbol named in a packet's contracts;
- an external change moves the base branch or a dependency the plan relies on;
- a unit is put on hold, closed without merge, or replaced by another unit.

After two redesigns of one unit, return to the requirements approval checkpoint instead
of a third packet version. Realignment refreshes `run.md`, the index, the glossary,
aliases, invalidations, and every published file it reaches, including `Status:` lines.

### 6. Recover and report

The orchestrator reads `run.md`, `artifact-index.md`, packet versions, worktree
state, commits, checks, and review findings. For a failure, preserve the failed
worktree and evidence, then retry or repair only that unit. Do not restart accepted
units.

If a repair changes a contract, mark dependent packets `invalidated`, regenerate only
those packets, and return them to Ponytail spec review. If state disagrees with Git or
the filesystem, preserve both views and block for reconciliation. Never infer success
from chat history.

Invoke `final-report` when all reachable units finish, and also when the run enters
`parked`, `pivoted`, `abandoned`, or `failed`. A run that goes idle after a merge with
unbuilt units is `parked` and gets a report. Report each unit, checks, Ponytail
findings, glossary reconciliation, unresolved risks, deferred work, artifact paths,
blocked recovery actions, and where the accurate end-state description now lives.

## Approval and execution rules

- No sequencing or build before explicit human approval of the Ponytail-approved
  technical-spec set.
- No build from a packet version without an accepted Ponytail row and a human record
  naming that version.
- No resume from a failed or awaiting-review state without reading persisted artifacts.
- No build from a stale, invalidated, or superseded packet.
- No dependent unit before its blocking prerequisite is ready.
- No scope from chat; scope arrives only through a packet version.
- No edit to an accepted artifact; changes produce the next version.
- No cleanup of failed worktrees or branches until recovery is complete.
- No claim without evidence or an explicit `unknown`.
- No context packet that exceeds the bounds in the context contract.
- No checkpoint request, builder dispatch, or final report without a passed consistency
  check.
- No final success claim when required checks, reviews, or artifacts are missing.

When review is pending, preserve completed artifacts and report the exact action needed.
When blocked, report the smallest decision or reconciliation needed. Never silently
realign or discard work.
