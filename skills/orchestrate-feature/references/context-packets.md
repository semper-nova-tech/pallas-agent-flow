# Context Packet Contract

Agents exchange artifacts and bounded packets, never transcripts. A packet should be
small enough to inspect in one pass; target 800 words and do not exceed 1,500 words
excluding direct file references.
Apply [human-readable-output.md](human-readable-output.md) to packet contents, artifact
paths, and all returned narration.

## Required packet fields

- packet display name, one-sentence purpose, `packet-id`, `run-id`, and intended role
- objective and explicit non-goals
- target repository and allowed scope
- accepted input names, with IDs, versions, and paths as metadata
- non-authoritative sources: notes, brainstorms, or superseded drafts the recipient
  must not import behavior from, or `none`
- guidance manifest path and version
- relevant named requirements, with IDs for traceability
- named decisions and consequences that constrain the task
- dependencies and current status
- required outputs and exact destination paths
- verification expectations
- blockers or questions the recipient may escalate
- a separate `Open questions` section

Include evidence excerpts only when a path and symbol are insufficient. Never include
chat history, hidden reasoning, full discovery logs, or unrelated source files.

## Guidance manifest

The orchestrator creates one guidance manifest for each implementation packet under
`.lore-flow/runs/<run-id>/guidance/<packet-id>.md`. The manifest is a bounded list
of applicable repository guidance, not a copy of its contents.

Each entry records:

- repository-relative path;
- kind: `AGENTS.md`, `cursor-rule`, or `skill`;
- why it applies to the packet;
- content hash from the approved repository state;
- status: `required`, `recommended`, or `not-applicable`.

The packet references the exact manifest version. Builders read it before mutation and
record the guidance they used in the build report. They may mark an entry skipped only
with a short reason. Do not report harness-internal system prompts or duplicate full rule
contents.

## Discovery packet

Add:

- area: `frontend`, `backend`, or `infrastructure`
- PRD frontier summary
- questions the report must answer
- known repository entry points, if any

The result must provide observed evidence, conventions, likely change surfaces, commands,
risks, unknowns, and existing architecture/ADR paths and relevant documents. Discovery
does not design or edit.

## Planning packet

Add:

- accepted PRD review path
- discovery index and three discovery report paths
- product decisions and constraints

The result must use named model/contract/state/behavior requirements and a dependency
graph. Include published spec, architecture-overview, and systems-summary paths, plus
architecture impact and any domain run-draft outputs. Include the diagram policy and each
selected diagram's purpose, type, home, source requirements, and validation convention.
It must not rely on unstated transcript context.

## Build packet

Add:

- PR name, plain-language purpose, internal ID, area, dependency, and worktree policy
- named requirements in scope, with exact IDs as metadata
- acceptance checks and repository-native test commands
- allowed paths or components and explicit exclusions
- guidance manifest path and exact version
- contracts consumed or exposed
- rollout/configuration duties
- published PR note and owned architecture-overview facet paths
- assigned durable architecture/ADR paths and any domain run-draft sources
- approved diagrams assigned to those docs and their source requirement IDs
- architecture/ADR paths explicitly outside this PR's ownership
- diagrams explicitly outside this PR's ownership
- required build-report path
- approving sequence review ID and approved packet/input versions

For infrastructure, specify both local and hosted configuration acceptance. For an
approved frontend-leading stub, include exactly:

`button calls unimplemented endpoint - no-op for now`

The builder may inspect the repository for implementation details but must escalate any
change that expands named requirements, crosses area boundaries, or touches an
unassigned architecture document. It verifies changed documentation links, examples,
commands, configuration references, and assigned diagram syntax/rendering.

Before mutation, the builder verifies that the packet and every accepted input version
match the approving review and artifact index. Reject any draft, invalidated, replaced,
or superseded version. Human approval of a different version does not carry forward.

## Review packet

Add:

- review mode: `pre-build` or `post-build`
- baseline artifact IDs
- diff reference for post-build review
- checks already run and summarized results
- diagram policy, assignments, and validation evidence in scope

The result separates blocking findings, non-blocking findings, rejected concerns, and
evidence. Every finding names the violated requirement, observed risk, or YAGNI reason.

## Human approval packet

Add:

- approval checkpoint name, internal ID, and plain-language reason
- reviewer or reviewer policy
- published pack paths as the primary review files
- readable artifact names, with exact IDs and versions as metadata
- required diagram coverage or single-PR no-diagram statement
- concise change summary, decisions, risks, and unresolved questions
- allowed decisions: `approved`, `changes-requested`, or `rejected`
- effect of each decision and resume instructions
- numbered named approval actions and their consequences
- each destructive action as a separate approval naming the exact target and consequence
- a separate `Open questions` section

Do not ask for approval of an unversioned artifact or combine destructive actions into a
bulk approval. A human edit is a proposed change and must be reconciled through
`realign-run`, not treated as approval.

## Realignment packet

Keep this packet at 800 words or fewer. Add:

- review name and ID, reviewer, decision, comments, and changed artifact versions
- classifications and old/new names or design facts
- affected architecture draft versions and durable documentation paths
- relevant dependency edges, alias entries, and current invalidation records
- accepted artifacts that must remain preserved
- affected branches, worktrees, packets, builds, and their current state
- requested readable output path and current pending approval checkpoint

Include only the graph slice reachable from changed artifacts plus immediate evidence.
The result returns proposed aliases, transitive impacts, minimal reruns, implementation
actions requiring approval, preserved artifact versions, and the next approval checkpoint.

## Return packet

Every delegated task returns no more than:

- outcome: `complete`, `clarification-required`, `changes-required`, or `blocked`
  (reviewers such as Ponytail use `accepted` for their verdict)
- summary of at most ten bullets
- created or updated artifact IDs and paths
- evidence/check summary
- decisions or blockers requiring parent action

Full detail belongs in the indexed artifact. The parent consumes the return packet and
artifact index, not the agent transcript. Workers never ask the human for approval or
decisions; they return decision requests to the orchestrator.
