---
name: plan-requirements
description: Converts an accepted PRD frontier and stack discovery into named, testable technical requirements for model, contract, state, and behavior changes. Use before PR sequencing and implementation.
---

# Plan Requirements

Produce the technical contract for implementation. Requirements describe necessary
changes and acceptance, not line-by-line code.

## Inputs

- accepted readable PRD review artifact
- `discovery-index.md` and all three area reports
- decisions, constraints, and explicit non-goals
- output path under the run root

Do not rely on conversations or transcripts. If an input is missing or contradictory,
return `blocked` with the exact artifact or decision needed.
Apply the orchestrator human-readable output policy to every created element and path.
Mint the published technical spec, systems summary, and architecture overview per the
orchestrator published-docs policy. Do not copy them into the run folder.

## Requirement taxonomy

Every change must be a named requirement of one of these types:

- `MODEL`: domain or persisted data shape, invariant, lifecycle, or migration
- `CONTRACT`: API, event, command, schema, integration, or cross-area boundary
- `STATE`: client/server state, transition, synchronization, caching, or failure state
- `BEHAVIOR`: observable user, system, operational, or accessibility behavior

Give each requirement a display name and plain-language meaning, with an ID such as
`MODEL-user-preference` as secondary metadata. It must have one primary type and owner.

## Process

1. Map every PRD frontier item to one or more named requirements.
2. Reuse discovered conventions and contracts where they satisfy the frontier.
3. Define inputs, outputs, invariants, failures, and compatibility where relevant.
4. Assign exactly one owner: `frontend`, `backend`, or `infrastructure`.
5. Record dependencies between requirement IDs.
6. Define objective acceptance checks and evidence expected from builds.
7. Mark rollout, migration, local configuration, and hosted configuration duties.
8. For each requirement, record architecture impact (`none`, `update`, or `decision`) and
   exact durable architecture/ADR updates using discovered repository conventions.
9. Apply the orchestrator diagram policy. Before requirements approval, select each
   required diagram and record its purpose, type, home, and source requirement IDs.
10. Embed selected diagrams in the published architecture overview.
11. Verify that each requirement is necessary; leave implementation choices open unless
    the choice is itself required for compatibility or correctness.

Do not hide cross-area work in one requirement. Split it at the contract boundary.

## Published architecture and spec

When a change meaningfully alters system boundaries, contracts, data flow, deployment,
or a consequential design decision, write the committed architecture overview with the
end state, simple object models, contracts, and justified diagrams. Give each facet a
stable heading. Write the technical spec with full PRD-derived behaviors. Write the
systems summary as the feature README.

Git history versions the published docs; do not keep copies under the run root. Write
domain drafts under `architecture/` only for durable domain docs a PR will own later.
Do not create published docs for trivial implementation details. Record `none` when architecture is unchanged. Use
embedded Mermaid unless discovery found a repository-native alternative.

## Output contract

Write `docs/features/<feature-slug>/{README,technical-spec,architecture-overview}.md`.
`technical-spec.md` is the requirements document and uses this shape after its
behavior sections:

```markdown
# Technical Requirements
Status: complete | clarification-required | blocked

## Scope and constraints
## Requirement index
## Requirements
### Create widget contract (`CONTRACT-create-widget`)
- Meaning:
- Type: CONTRACT
- Owner: backend
- Frontier: [frontier name and internal ID]
- Purpose:
- Inputs/outputs:
- Invariants and failures:
- Depends on:
- Acceptance checks:
- Evidence:
- Architecture impact: none | update | decision
- Durable docs/ADRs: [exact target paths and action, or none]
- Domain drafts: [run `architecture/` paths, or none]
- Non-goals:
## Dependency graph
## Cross-area contracts
## Architecture documentation plan
### Diagram plan
- Purpose:
- Type: flowchart | sequenceDiagram | stateDiagram-v2
- Home:
- Source requirements:
- Convention and validation:
## Migration and rollout
## Local and hosted configuration
## Coverage matrix
## Numbered decisions and consequences
## Open questions
```

The coverage matrix maps every frontier item to requirement IDs and every requirement to
an acceptance check. No orphan frontier items or requirements are allowed.

## Approval checkpoint

Return `complete` only if requirements are named, necessary, testable, area-owned, dependency-aware,
evidence-backed, and explicit about architecture documentation and justified diagram
coverage. Every selected diagram must already be in the published architecture overview.
Escalate product choices to the orchestrator; do not resolve them as technical details
or ask the human directly.
Return status, counts by type and owner, blockers, and the published paths.
