---
name: plan-requirements
description: Converts an accepted PRD frontier and stack discovery into named, testable technical requirements for model, contract, state, and behavior changes, each stating today and after, bound to feature glossary rows. Use before PR sequencing and implementation.
---

# Plan Requirements

Produce the technical contract for implementation. Requirements describe necessary
changes and acceptance, not line-by-line code. The feature glossary owns names and
surfaces; this spec owns shapes.

## Inputs

- accepted readable PRD review artifact
- `discovery-index.md` and all area reports
- feature glossary path
- decisions, constraints, and explicit non-goals
- published pack paths

Do not rely on conversations or transcripts. If an input is missing or contradictory,
return `blocked` with the exact artifact or decision needed.
Apply the orchestrator human-readable output policy to every created element and path.
Mint the published technical spec, systems summary, and architecture overview per the
orchestrator published-docs policy. Do not copy them into the run folder. Write nothing
under `pull-requests/`; packets belong to `sequence-prs`.

## Requirement taxonomy

Every change must be a named requirement of one of these types:

- `MODEL`: domain or persisted data shape, invariant, lifecycle, or migration
- `CONTRACT`: API, event, command, schema, integration, or cross-area boundary
- `STATE`: client/server state, transition, synchronization, caching, or failure state
- `BEHAVIOR`: observable user, system, operational, or accessibility behavior

Give each requirement a display name and plain-language meaning, with an ID such as
`MODEL-user-preference` as secondary metadata. It must have one primary type and owner.
Behavior names are verb-first; model names are nouns.

## Process

1. Map every PRD frontier item to one or more named requirements.
2. Reuse discovered capabilities, conventions, and contracts where they satisfy the
   frontier. Prefer an `existing` glossary row over a `new` one; a new row for a concept
   that an existing row already covers is a defect.
3. For each requirement write `Today:` (observed, with evidence) and `After:` (one
   sentence of observable end state).
4. Bind surfaces in the glossary: for every `new` row the requirement uses, fill the
   model type, verb-first function names, module, and wire name. Modules are named after
   the term and follow the repository's project naming convention.
5. Define inputs, outputs, invariants, failures, and compatibility where relevant.
6. Assign exactly one owner: `frontend`, `backend`, or `infrastructure`.
7. Record dependencies between requirement IDs.
8. Define objective acceptance checks and evidence expected from builds.
9. Mark rollout, migration, local configuration, and hosted configuration duties.
10. For each requirement, record architecture impact (`none`, `update`, or `decision`) and
    exact durable architecture/ADR updates using discovered repository conventions.
11. Apply the orchestrator diagram policy. Before requirements approval, select each
    required diagram and record its purpose, type, home, and source requirement IDs.
12. Embed selected diagrams in the published architecture overview.
13. List every fact the plan depends on that discovery marked `assumed` or `unknown`
    under Facts to verify before build, with an owner and the checkpoint where it is
    checked. A requirement may not name a dependency, protocol, or capability that
    discovery did not observe.
14. Verify that each requirement is necessary; leave implementation choices open unless
    the choice is itself required for compatibility or correctness.
15. When ownership or boundary is a choice (edit another team's library versus add an
    in-domain one; existing transport versus new), present it as a numbered decision
    with options and consequences rather than choosing silently.

Do not hide cross-area work in one requirement. Split it at the contract boundary.

## Published architecture and spec

When a change meaningfully alters system boundaries, contracts, data flow, deployment,
or a consequential design decision, write the committed architecture overview with
`## Today → After` first, then simple object models, contracts, and justified diagrams,
all using glossary names. Give each facet a stable heading. Write the technical spec
with full PRD-derived behaviors. Write the systems summary as the feature README.

Git history versions the published docs; do not keep copies under the run root. Write
domain drafts under `architecture/` only for durable domain docs a PR will own later.
Do not create published docs for trivial implementation details. Record `none` when
architecture is unchanged. Use embedded Mermaid unless discovery found a
repository-native alternative.

## Output contract

Write `docs/features/<feature-slug>/{README,technical-spec,architecture-overview}.md`
and update `glossary.md`. `technical-spec.md` is the requirements document and uses this
shape after its behavior sections:

```markdown
# Technical Requirements
Status: planned

## Changed since v<n-1>   (v2 and later only)
## Terms
## Scope and constraints
## Requirement index
## Requirements
### Create widget contract (`CONTRACT-create-widget`)
- Meaning:
- Today:
- After:
- Type: CONTRACT
- Owner: backend
- Frontier: [frontier name and internal ID]
- Terms: [glossary rows used]
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
## Facts to verify before build
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
an acceptance check, written out in full; a placeholder row such as "see each
requirement" is a defect. No orphan frontier items or requirements are allowed. No cell
may say "as v1" or defer to an earlier version; every version is self-contained.

## Approval checkpoint

Return `complete` only if requirements are named, necessary, testable, area-owned,
dependency-aware, evidence-backed, bound to glossary rows, explicit about today and
after, and explicit about architecture documentation and justified diagram coverage.
Every selected diagram must already be in the published architecture overview.
Escalate product choices to the orchestrator; do not resolve them as technical details
or ask the human directly.
Return status, counts by type and owner, glossary rows bound, facts to verify, blockers,
and the published paths.
