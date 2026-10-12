---
name: final-report
description: Produces the concise, evidence-backed Lore Flow completion report across PR sequencing, requirement coverage, glossary reconciliation, builds, checks, reviews, risks, and artifacts. Use at every terminal state of a run, including parked, pivoted, and abandoned.
---

# Final Report

Summarize the run from indexed artifacts. Do not reconstruct events from transcripts or
claim success from agent confidence. A run that stops for any reason gets a report; a
report that says where the work stands is more useful than no report.

## Inputs

- run manifest and artifact index
- accepted PRD review and technical requirements
- feature glossary and aliases
- PR sequence and build packets
- build reports and post-build Ponytail reviews
- mandatory human review records and any realignment artifacts
- decision log and invalidations
- published feature pack paths and durable documentation assignments
- indexed architecture draft versions
- indexed diagram coverage and build validation evidence

Validate that referenced artifacts exist, their versions match mandatory approvals, and
their statuses agree. A missing, conflicting, stale, invalidated, or superseded input is
an explicit report finding and cannot support `completed`.
Apply the orchestrator human-readable output policy to the report and all narration.

## Determine outcome

Use one outcome:

- `completed`: every in-scope requirement has build evidence, required checks, an
  accepted post-build review, and every assigned durable doc/ADR update is verified
- `partially-completed`: useful PRs are ready but one or more requirements are blocked
- `parked`: the run went idle with units unbuilt and no blocker
- `pivoted`: the plan was replaced by work outside the sequence
- `abandoned`: the human stopped the run
- `blocked`: implementation cannot proceed or no PR is ready
- `failed`: required execution or verification failed without a safe handoff

Do not convert `not-run`, `unknown`, or missing evidence into a pass. Distinguish code
readiness from merge, deployment, or production validation.

## Reconcile

Before writing:

1. Map every frontier item to named requirements.
2. Map every requirement to its owning PR and outcome.
3. Reconcile the glossary: for every row with a Module, check the module's public
   exports for the Model, Functions, and Wire name columns. Report each row as
   `match`, `renamed` (with the alias row), `not shipped` (with the decision), or
   `export without a term` for symbols that have no row.
4. Confirm dependency and recommended merge order.
5. Summarize tests and checks by PR, including failures and omissions.
6. Confirm each post-build Ponytail outcome.
7. For infrastructure, report local and hosted configuration separately.
8. Collect decisions, deviations, residual risks, and intentionally deferred work.
9. Confirm requirements and sequence approvals identify the versions that were built.
10. Summarize realignments, aliases, supersession, and preserved unaffected work.
11. Confirm the published pack state and every `Status:` line. State where the accurate
    end-state description lives now, especially after a pivot.
12. Confirm each durable architecture doc/ADR was assigned once and verified.
13. Confirm each required diagram's purpose, type, home, source requirements, delivery,
    and syntax/rendering evidence. Report justified no-diagram decisions.
14. Promote glossary rows that other features will reuse to `product/GLOSSARY.md` when
    that file exists, listing the rows promoted.
15. Identify the smallest next action for every blocker and every unbuilt unit.

## Output contract

Write `reports/<feature-slug>-final.md`:

```markdown
# Lore Flow Final Report
Display name:
Plain-language purpose:
Internal ID:
Outcome: completed | partially-completed | parked | pivoted | abandoned | blocked | failed

## Executive summary
## Where things stand
## Deliverables and PR order
## Frontier and requirement coverage
## Glossary reconciliation
## Checks and review evidence
## Configuration and rollout
## Published review pack and where the end state is described
## Architecture documentation coverage
### Diagram coverage and validation
## Decisions and deviations
## Realignments and aliases
## Open questions
## Risks, blockers, and next actions
## Deferred and out-of-scope work
## Artifact index
```

For each PR report:

- PR ID, display name, area, worktree/branch or diff reference
- requirement IDs and dependency
- build outcome and post-build review outcome
- checks: passed, failed, and not run
- merge or handoff readiness

Use links or paths to detailed artifacts instead of copying their contents. Keep the
executive summary to ten bullets or fewer. Copy the Where things stand table from
`run.md` as of the report.

## Return

Return the overall outcome, ordered PR list, glossary mismatches, critical evidence,
unresolved blockers, and the readable final-report path. State whether commits, pushes,
PR creation, merges, deployment, and hosted validation occurred; never imply external
actions without evidence.
