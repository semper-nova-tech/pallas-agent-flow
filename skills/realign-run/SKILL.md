---
name: realign-run
description: Reconciles explicit human edits, review changes, mid-build instructions, and scope pivots; preserves history, refreshes run state and published docs, and returns the next approval checkpoint. Use whenever a human changes course after an artifact was accepted.
---

# Realign Run

Reconcile human changes without silently rewriting an accepted plan. Preserve accepted
artifacts, decisions, and implementation work until the reviewer approves a safe path.

## Triggers

The orchestrator invokes this skill, never the worker, when:

- a checkpoint reply is anything other than `approved`, `changes-requested`, or
  `rejected`, or an approval carries answers that change a contract, path, owner,
  dependency, protocol, or term meaning;
- an instruction during a build changes a unit's contract, scope, or names;
- a review commit renames or removes an exported symbol named in a packet;
- an external change moves the base branch or a dependency;
- a unit is put on hold, closed without merge, replaced, or the run is parked, pivoted,
  or abandoned.

## Inputs

Require:

- run ID and absolute run root
- the trigger, reviewer identity, decision, and comments
- changed naming, requirement, design, sequencing, or scope artifacts
- current run manifest, artifact index, glossary, aliases, decisions, reviews, and
  dependency graph

Also inspect existing branches, worktrees, and build reports when implementation exists.
Treat direct human edits as proposed changes, not implicit approval.
Apply the orchestrator human-readable output policy throughout.

## Classify the change

Assign every change one or more classes:

- `rename-only`: labels change, but meaning and acceptance stay equivalent
- `requirement`: frontier, acceptance, ownership, or necessity changes
- `contract-model-state-behavior-design`: a technical design boundary changes
- `sequencing`: PR grouping, dependencies, order, or parallelism changes
- `scope`: included, excluded, deferred, on-hold, replaced, or cross-area work changes

Check every changed name against the feature glossary. A change that edits a row's
Meaning, or introduces a wire name, module, or tool whose noun has no row, is `scope`,
never `rename-only`. If a rename changes meaning, classify the semantic change too.
Record uncertainty and ask the reviewer; never downgrade a change to reduce reruns.

For every design or naming change, record impact on the published spec, architecture
overview, glossary, sequence, PR notes, run drafts, and durable architecture/ADR paths.
A design change regenerates only affected drafts and revalidates their durable-doc
assignments. A `rename-only` change updates the glossary row, adds an alias row, and
refreshes only documents that contain the affected name; it does not rewrite unrelated
architecture.

Apply the same bounds to embedded diagrams. Refresh only diagrams reached by the changed
requirements, contracts, topology, state, or sequence; preserve unaffected diagrams.
For `rename-only`, use the alias map to refresh affected labels while keeping stable node
IDs and relationships. Revalidate changed diagrams without creating decorative ones.

## Preserve history

1. Never edit an accepted artifact. Write the candidate as `v<n+1>` at the readable
   path and move the accepted version to `superseded/<readable-path-without-ext>/v<n>.md`
   in the same step.
2. Open every candidate with `## Changed since v<n>` listing Added, Changed, and Removed
   with the section each touches. Removed may not be empty when a requirement, check,
   or PR disappeared.
3. Link the candidate to its predecessor and review record in the index.
4. Keep prior accepted decisions and artifacts addressable.
5. Record why each new version differs and who requested it.
6. Mark an artifact `superseded` only after its replacement is accepted; mark it
   `invalidated` in the meantime.
7. A replaced design gets a new PR ID and display name, never a new version of the old
   ID.

For `rename-only`, add old-to-new names to `aliases.md` before any artifact uses the new
name. Keep stable IDs where meaning is unchanged and preserve reverse traceability from
the new label to prior evidence, requirements, packets, builds, and reviews. Change a
readable filename only through the explicit realignment plan and record old/new path
aliases.

## Compute transitive impact

Start from changed artifact IDs and traverse declared input, requirement, contract,
glossary-row, and PR dependency edges. Produce one `invalidations.md` row per reachable
artifact:

- source change and classification
- dependency path that makes the artifact reachable
- impact: `none`, `label-refresh`, `revalidate`, or `regenerate`
- affected architecture draft versions and durable document/ADR paths
- rationale and proposed action

Do not invalidate an artifact merely because it is later in time. Unaffected branches of
the graph remain accepted. A rename normally requires alias-aware label refresh, not
design or build invalidation. A changed contract invalidates only its requirements,
producer/consumer sequence nodes, packets, and builds that rely on that contract.

## Select the minimal rerun

Use the earliest materially impacted phase:

- PRD review for changed product scope or frontier
- discovery only when repository facts must be re-observed
- requirements planning for requirement or technical design changes
- pre-build Ponytail for any materially changed requirements
- PR sequencing for dependency, grouping, area, or order changes
- packet generation for affected PRs only
- build and post-build review for affected implementation only

A unit that has already been redesigned twice returns to the requirements checkpoint
rather than receiving a third packet version.

## Existing implementation safety

If branches, worktrees, commits, or builds exist, describe their current state and propose
one action for each affected unit:

- `keep`: still valid against approved artifacts
- `rebase`: retain work on a newly approved dependency or base
- `replace`: preserve evidence, then rebuild from a replacement packet
- `cancel`: preserve the worktree/branch record and stop the unit

State data-loss, conflict, and review risks. Require explicit human approval before
rebasing, deleting, replacing, resetting, force-updating, or cancelling implementation.
Until approval, leave implementation untouched and set status `awaiting-human-review`.
Present every destructive action as its own numbered approval item. Name the exact file,
worktree, or branch and consequence; never combine it with another approval.

## Refresh run state

In the same step as the realignment record:

- regenerate the Where things stand table in `run.md`, set `status` and
  `current-phase`, and strike superseded decisions with their replacements;
- add index rows for every candidate and mark reached rows `invalidated`;
- update glossary rows and `aliases.md`;
- rewrite the `Status:` line and the `Changed since` section of every published file
  the change reaches;
- run the consistency check and record its result.

## Output

Write `realignments/<change-slug>.md` containing:

- display name, plain-language purpose, `RA-<nnn>`, trigger, reviewer, decision,
  comments, and timestamp
- changed artifact IDs and before/candidate versions
- change classifications, glossary rows affected, and alias updates
- published pack, architecture draft, and durable-document impact
- impacted diagrams, preserved diagrams, and validation needed
- transitive impact records and unaffected accepted artifacts
- minimal phases and affected PRs to rerun
- existing-build proposals and approvals required
- supersession plan, named numbered decisions and consequences, unresolved questions,
  and next approval checkpoint
- a separate `Open questions` section

Update the artifact index, decision history, review records, and run status without
overwriting prior entries. Return a bounded summary with the artifact path.

## Approval checkpoint

The next approval checkpoint is the earliest impacted mandatory checkpoint: technical
requirements or PR sequence. If neither is materially impacted, request approval of the
realignment plan before resuming. Explain what changed, what is no longer trustworthy,
and what needs review. Resume only from approval naming the candidate versions.
