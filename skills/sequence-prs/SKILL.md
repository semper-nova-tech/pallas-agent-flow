---
name: sequence-prs
description: Splits human-approved Lore Flow requirements into dependency-aware frontend, backend, and infrastructure pull requests with bounded build packets, guidance manifests, and owned glossary rows. Use after pre-build Ponytail and human requirements approval.
---

# Sequence PRs

Create the smallest reviewable PR sequence that preserves requirement and runtime
dependencies. This is the only skill that writes packets.

## Inputs

- Ponytail-approved published technical spec and glossary, at exact versions
- human requirements review approving those versions
- discovery index
- decision log
- repository and PR constraints
- run artifact root (absolute)

Apply the orchestrator human-readable output policy to PRs, sequence, packets, and
approval narration. Mint published `sequence.md` and terse per-PR notes per the
orchestrator published-docs policy. Keep packets in the run folder.

## Hard boundaries

Each PR has exactly one area:

- `frontend`
- `backend`
- `infrastructure`

Never mix areas in one PR, even for a small change. Split at named contracts and express
the dependency. A backend PR that carries an infrastructure file is two PRs.

Each PR has exactly one display name, verb-first, used verbatim as the sequence entry,
packet title, PR note title, build report title, index name, branch intent, and Git PR
title. Record it as a glossary row of kind `module` when the PR creates a library, or
in the sequence table otherwise.

Assign every planned durable architecture document or ADR update to exactly one PR.
Domain documents follow their frontend, backend, or infrastructure owner. Cross-cutting
API/contract architecture belongs to the contract-producing backend PR by default.
Infrastructure documentation always remains in an infrastructure PR. If ownership is
genuinely ambiguous, block for a human decision; never create a mixed-area documentation
PR.

Default ordering is backend before frontend so the implemented contract exists before
its consumer. Frontend may lead only when independently reviewable and explicitly
approved. If it contains a control for an absent endpoint, its packet and PR description
must include exactly:

`button calls unimplemented endpoint - no-op for now`

Place infrastructure last unless a net-new resource blocks implementation. A blocking
resource is something application code cannot develop or verify without, not merely
configuration that is convenient to prepare first. Infrastructure scope must include
both local and hosted configuration and their validation.

## Sequencing process

1. Group named requirements by owning area and cohesive review purpose.
2. Split groups further when they can merge independently or carry distinct risk.
3. Create a directed dependency graph between PRs.
4. Apply ordering defaults and document every exception.
5. Ensure every requirement appears in exactly one primary PR.
6. Assign every glossary row with a Module or Wire name to exactly one PR; that PR may
   export those symbols and no others.
7. Assign every durable architecture/ADR path exactly once and ensure its area matches.
8. Define contract assumptions for consumers and producers.
9. Create one guidance manifest per PR at `guidance/<pr-id>.md`, listing only tracked
   paths with hashes at the approved commit.
10. Generate one bounded build packet per PR using the orchestrator packet contract,
    including the absolute run root, owned glossary rows, verification access, and the
    five-line Before / After / See it / Files / Checks block filled as far as planning
    allows. A packet may not name a dependency that discovery did not observe.
11. Check that no cycle exists; if one does, refine contracts or report a decision need.
12. When there is more than one PR, embed a Mermaid dependency DAG in published
    `sequence.md`. For one PR, state that no dependency diagram is needed.
13. Write one published PR note per item with the five-line block, the glossary rows it
    implements, links to architecture-overview facets, and terse pseudo-code or a
    nominal-flow diagram for that PR only.

Do not sequence speculative cleanup, opportunistic refactors, or requirements rejected by
Ponytail.

## Output contract

Write published `docs/features/<feature-slug>/sequence.md` and `prs/*.md`. Keep the
detailed packet under the run folder at
`pull-requests/<nn>-<domain>-<purpose-slug>-packet.md`.

```markdown
# Pull Request Sequence
Status: planned

## Changed since v<n-1>   (v2 and later only)
## Ordering rationale
## Dependency graph
[embedded Mermaid DAG, or single-PR no-diagram statement]
## Sequence
### [PR display name] (PR-<nn>)
- Meaning:
- Area: backend
- Requirements:
- Glossary rows owned:
- Depends on:
- Contract produced/consumed:
- Durable architecture docs/ADRs owned:
- Architecture draft sources:
- Worktree branch intent:
- Verification access:
- Acceptance checks:
- Packet: [readable packet path]
- Guidance manifest: [path and version]
## Coverage
## Exceptions and approvals
## Risks and blockers
```

## Approval checkpoint

Mark ready for human review only when the graph is acyclic, areas are strictly separated,
ordering is justified, infrastructure covers local and hosted concerns, every packet has
every required field, every glossary row with a surface is owned by exactly one PR, and
all requirements and durable documentation updates are covered exactly once. The
required PR DAG or single-PR no-diagram statement must be available at this checkpoint.
Do not mark the sequence or packets approved and do not start builds. Return the
published sequence and PR-note paths, packet and manifest paths, exact versions,
parallelizable PRs, and blockers.
