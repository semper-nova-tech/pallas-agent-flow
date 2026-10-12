---
name: discover-stack
description: Discovers one frontend, backend, or infrastructure area of a repository and produces an evidence-backed change-surface report, including what already exists so planning reuses it. Use during parallel Lore Flow stack discovery before requirements planning.
---

# Discover Stack

Investigate exactly one area: `frontend`, `backend`, or `infrastructure`. Discovery is
read-only and evidence-first. Do not propose speculative architecture or edit code.

## Inputs

- bounded discovery packet
- target repository path
- area
- accepted PRD review path and feature glossary path
- output path under the run root

Read only the artifacts and repository regions needed to answer the packet questions.
Apply the orchestrator human-readable output policy to created items and artifacts.

## Common discovery

Identify:

- project layout, ownership boundaries, and relevant entry points
- languages, frameworks, package/build tools, and repository-native commands
- existing patterns closest to each frontier item
- likely files, symbols, modules, and tests affected
- contracts crossing area boundaries
- the area's existing architecture and ADR locations, naming/index conventions, and
  relevant current documents
- existing diagram formats, Mermaid conventions, durable homes, and validation commands
- existing feature-doc convention, or default `docs/features/<feature-slug>/`
- constraints, risks, unknowns, and assumptions requiring validation

## What already exists

The largest reversals in past runs came from designing something the repository or an
installed package already provided. Before anything new is named, record:

- **Existing capabilities**: every exported symbol of each library the frontier touches,
  with a one-line meaning. Add each as an `existing` glossary row with its model,
  functions, module, and wire name filled from the code.
- **Installed protocols and SDKs**: for each package that touches the frontier, its
  installed version and the events, schemas, tools, or middleware it already provides.
  Name the exact file and line in the lockfile or package manifest.
- **Integrations**: for every external system the PRD names, how the repository already
  reaches it (client library, MCP server, HTTP, queue), the auth mode and token audience,
  the configuration keys, and the closest existing call site.
- **Provider constraints**: for every model or provider the PRD names, documented
  limits that affect the frontier, such as tool-choice or thinking restrictions.

A planner may not name a dependency, protocol, or capability that this section did not
observe. A gap here is an `unknown` with a validation owner, not a guess.

Every material statement must cite a repository-relative path with line range or symbol,
a summarized command result, or an accepted artifact. Distinguish observed facts from
inferences.

Produce a current-state diagram only when repository evidence supports every component
and relationship complexity materially benefits from a visual. Embed it in the relevant
discovery report, follow the repository convention, and apply the orchestrator diagram
policy. Otherwise state that no discovery diagram is justified.

## Area focus

### Frontend

Inspect routing, composition, state management, forms, validation, accessibility,
loading/error/empty states, API clients, test conventions, and feature flags.

### Backend

Inspect transport contracts, domain models, validation, authorization, persistence,
transactions, idempotency, errors, observability, migrations, and test conventions.

### Infrastructure

Inspect local development and hosted environments together: configuration schema,
environment variables, secrets references, provisioning, deployment, networking,
permissions, migrations, observability, rollback, and CI/CD. Determine whether any
net-new resource blocks application implementation.

## Output contract

Write `discovery/<feature-slug>-<area>.md`:

```markdown
# [Area] Discovery
Status: complete | blocked
Display name:
Plain-language purpose:
Internal ID: DISC-<area>

## Summary
## Evidence
## What already exists
### Existing capabilities
### Installed protocols and SDKs
### Integrations
### Provider constraints
## Glossary rows added
## Existing architecture and conventions
### Durable documentation convention
- Architecture paths/indexes:
- ADR paths/indexes and numbering/status:
- Relevant current documents:
- Diagram conventions and validation tooling:
- Evidence or `none found`:
## Frontier change surfaces
- [frontier name and internal ID]
  - Likely files/symbols:
  - Existing analogous pattern:
  - Cross-area contracts:
## Native commands and checks
## Risks and constraints
## Unknowns and validation owners
## Open questions
## Planning recommendations
```

Planning recommendations identify constraints and reusable patterns, not a complete
solution. Do not invent requirements.

## Return

Return no more than ten bullets containing status, strongest findings, existing
capabilities that satisfy frontier items, blocking unknowns, glossary rows added, and
the report path. The orchestrator builds `discovery-index.md` from these summaries; do
not pass raw logs or repository dumps.
