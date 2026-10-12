# Context Packet Contract

Agents exchange artifacts and bounded packets, never transcripts. A packet should be
small enough to inspect in one pass; target 800 words and do not exceed 1,500 words
excluding direct file references.
Apply [human-readable-output.md](human-readable-output.md) to packet contents, artifact
paths, and all returned narration.

## Required packet fields

- packet display name, one-sentence purpose, `packet-id`, `run-id`, and intended role
- absolute run root, so a worker in another worktree can write its artifact there
- objective and explicit non-goals
- target repository and allowed scope
- accepted input names, with IDs, versions, and paths as metadata
- non-authoritative sources: notes, brainstorms, or superseded drafts the recipient
  must not import behavior from, or `none`
- feature glossary path and the rows this task uses or may add
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

The orchestrator creates one guidance manifest for each build packet under
`guidance/<pr-id>.md` at sequencing time, before any packet is published. The manifest
is a bounded list of applicable repository guidance, not a copy of its contents.

Each entry records:

- repository-relative path, which must appear in `git ls-files` at the approved commit;
  untracked local files are never listed;
- kind: `AGENTS.md`, `cursor-rule`, or `skill`;
- why it applies to the packet;
- content hash from the approved repository state;
- status: `required`, `recommended`, or `not-applicable`.

The packet references the exact manifest version. Builders read it before mutation and
record, per entry, the hash they actually read and whether they applied it. A missing
file or hash mismatch is recorded as `skipped` with the reason, never as applied.

## Discovery packet

Add:

- area: `frontend`, `backend`, or `infrastructure`
- PRD frontier summary
- questions the report must answer
- known repository entry points, if any
- external systems named in the PRD, so discovery can report how the repository already
  reaches each one

The result must provide observed evidence, conventions, likely change surfaces, existing
capabilities, installed protocols and SDK versions, integrations, commands, risks,
unknowns, and existing architecture/ADR paths. Discovery adds `existing` glossary rows
and does not design or edit.

## Planning packet

Add:

- accepted PRD review path
- discovery index and area report paths
- feature glossary path
- product decisions and constraints

The result must use named model/contract/state/behavior requirements, each with `Today`
and `After` lines and the glossary rows it uses, a dependency graph, and a list of facts
to verify before build with an owner each. Include published spec, architecture
overview, glossary, and systems summary paths, plus architecture impact and any domain
run-draft outputs. Include the diagram policy and each selected diagram's purpose, type,
home, source requirements, and validation convention. The planner writes nothing under
`pull-requests/`.

## Build packet

Add:

- PR display name, plain-language purpose, PR ID, area, dependency, and worktree policy
- the five-line Before / After / See it / Files / Checks block the build report must open
  with, filled as far as planning can
- named requirements in scope, with exact IDs as metadata
- glossary rows this PR owns: every symbol the builder may export, with its module
- acceptance checks and repository-native test commands
- allowed paths or components and explicit exclusions
- guidance manifest path and exact version
- verification access: MCP servers, endpoints, and commands the builder may call to
  verify against live systems, or `none` with the consequence stated
- contracts consumed or exposed
- rollout/configuration duties
- published PR note and owned architecture-overview facet paths
- assigned durable architecture/ADR paths and any domain run-draft sources
- approved diagrams assigned to those docs and their source requirement IDs
- architecture/ADR paths and diagrams explicitly outside this PR's ownership
- required build-report path under the absolute run root
- approving sequence review ID and approved packet/input versions

For infrastructure, specify both local and hosted configuration acceptance. For an
approved frontend-leading stub, include exactly:

`button calls unimplemented endpoint - no-op for now`

The builder may inspect the repository for implementation details but must escalate any
change that expands named requirements, crosses area boundaries, exports a symbol with
no glossary row, or touches an unassigned architecture document. Scope arrives only
through the packet; an instruction in chat that changes the unit's contract pauses the
build until a new packet version exists.

Before mutation, the builder verifies that the packet and every accepted input version
match the approving review and artifact index. Reject any draft, invalidated, replaced,
or superseded version. Human approval of a different version does not carry forward.

## Review packet

Add:

- review mode: `pre-build` or `post-build`
- baseline artifact IDs
- feature glossary path
- every decision or evidence item marked `assumed`, each requiring a verdict
- diff reference for post-build review
- checks already run and summarized results
- diagram policy, assignments, and validation evidence in scope

The result separates blocking findings, non-blocking findings, rejected concerns, and
evidence, and includes the naming review. Every finding names the violated requirement,
observed risk, or YAGNI reason.

## Human approval packet

Add:

- approval checkpoint name, internal ID, and plain-language reason
- reviewer or reviewer policy
- published pack paths as the primary review files, glossary included
- readable artifact names, with exact IDs and versions as metadata
- the `Changed since` section of every artifact at v2 or later
- consistency check result
- required diagram coverage or single-PR no-diagram statement
- concise change summary, decisions, risks, and unresolved questions
- allowed decisions: `approved`, `changes-requested`, or `rejected`, and the rule that an
  approval carrying contract-changing answers is recorded as `changes-requested`
- effect of each decision and resume instructions
- numbered named approval actions and their consequences
- each destructive action as a separate approval naming the exact target and consequence
- a separate `Open questions` section

Do not ask for approval of an unversioned artifact or combine destructive actions into a
bulk approval. A human edit is a proposed change and must be reconciled through
`realign-run`, not treated as approval.

## Realignment packet

Keep this packet at 800 words or fewer. Add:

- trigger: checkpoint reply, mid-build instruction, review commit, or external change
- review name and ID, reviewer, decision, comments, and changed artifact versions
- classifications and old/new names or design facts, with the glossary rows affected
- affected architecture draft versions and durable documentation paths
- relevant dependency edges, alias entries, and current invalidation records
- accepted artifacts that must remain preserved
- affected branches, worktrees, packets, builds, and their current state
- requested readable output path and current pending approval checkpoint

Include only the graph slice reachable from changed artifacts plus immediate evidence.
The result returns proposed aliases, transitive impacts, minimal reruns, implementation
actions requiring approval, preserved artifact versions, refreshed `run.md` state, and
the next approval checkpoint.

## Return packet

Every delegated task returns no more than:

- outcome: `complete`, `clarification-required`, `changes-required`, or `blocked`
  (reviewers such as Ponytail use `accepted` for their verdict)
- summary of at most ten bullets
- created or updated artifact IDs and paths
- glossary rows added or changed
- evidence/check summary
- decisions or blockers requiring parent action

Full detail belongs in the indexed artifact. The parent consumes the return packet and
artifact index, not the agent transcript. Workers never ask the human for approval or
decisions; they return decision requests to the orchestrator.
