# Lore Flow glossary

One canonical name per concept. Skills, references, agents, fixtures, and run
artifacts use these names and no synonyms.

| Term | Meaning | Avoid |
| --- | --- | --- |
| Run | One execution of Lore Flow for one ticket or PRD, identified by a run-id | job, session, flow instance |
| Run root | `.lore-flow/runs/<run-id>/` in the target repository; gitignored run machinery | run folder, run dir |
| Published pack | The committed review surface under `docs/features/<feature-slug>/` | review pack, docs pack, staging copy |
| Ticket | The issue the run delivers, written as `<KEY>-<number>` | story, task |
| Feature slug | Lowercase purpose slug derived from the ticket title; used in the run-id, published pack path, and artifact names | project slug, run slug |
| Frontier item | The smallest observable difference between current and requested behavior, found by `review-prd` | gap, delta item |
| Requirement | A named `MODEL`, `CONTRACT`, `STATE`, or `BEHAVIOR` change with acceptance checks, produced by `plan-requirements` | spec item, story |
| Technical spec | `technical-spec.md` in the published pack; the only requirements document | requirements doc, run requirements |
| Architecture overview | `architecture-overview.md` in the published pack; today and after, models, contracts, diagrams | design doc |
| Systems summary | `README.md` in the published pack | overview, summary page |
| Feature glossary | `glossary.md` in the published pack; the naming contract for every boundary-crossing term | terms list, dictionary |
| Term | One row of a glossary: a name, its meaning, and every surface it appears on | concept, entity |
| Surface | A place a term appears: model type, function, module, wire name, document heading | spelling, variant |
| Sequence | `sequence.md` in the published pack; PR order and dependency graph | plan, DAG doc |
| Pull request (PR) | One area-scoped, reviewable unit of implementation with a display name and sequence number | unit, work item, packet |
| PR note | `prs/<nn>-<domain>-<purpose-slug>.md` in the published pack; one screen describing a PR's slice | PR doc, PR summary |
| Packet | A bounded context document handed to one worker; build packets live under `pull-requests/` in the run root | brief, prompt, task |
| Build report | `pull-requests/<nn>-<domain>-<purpose-slug>-build.md`; one per build attempt | build log, builds file |
| Ponytail review | The adversarial review, run `pre-build` on the spec set and `post-build` on each PR diff | lint, leanness pass, over-building review |
| Approval checkpoint | A pause where only a human may record `approved`, `changes-requested`, or `rejected` | gate, approval gate, pause |
| Human review record | `human-reviews/<action>-<subject-slug>.md`; one file per checkpoint decision | approval file, review log |
| Decision | A named, numbered product or technical choice with its consequence | choice, answer |
| Open question | A question no artifact can answer yet, with a stable `Q-` slug | TBD, unknown (reserved for evidence) |
| Realignment | The `realign-run` record of a human change, its impact, and the next checkpoint | pivot doc, re-plan |
| Alias | A row in `aliases.md` mapping an old name or path to its replacement | rename record |
| Invalidation | A row in `invalidations.md` stating what changed, what can no longer be trusted, and what must be reviewed again | stale marker |
| Candidate | An artifact version written by a worker and not yet accepted | draft |
| Accepted | An artifact version the orchestrator has verified; immutable from then on | approved (reserved for humans) |
| Approved | A checkpoint decision recorded by a human for exact artifact versions | accepted (reserved for the orchestrator) |
| Superseded | An accepted version replaced by a later accepted version | archived, old |
| Invalidated | An accepted version that can no longer be trusted and has no accepted replacement yet | stale |
| Guidance manifest | `guidance/<pr-id>.md`; applicable repository instructions by tracked path and hash | rules list |
| Verification access | The MCP servers and commands a builder may call to verify against live systems | tool allowlist |
| Area | `frontend`, `backend`, or `infrastructure`; every PR and requirement has exactly one | domain, layer, stack |
| Owner | The area or team responsible for a requirement, document, or term | assignee |
| Display name | The short human-readable name every record leads with | title, label |
| Internal ID | The stable identifier kept as metadata for traceability | key, ref |
| Preset | A named policy in `config/presets.json`: harness, checkpoints, published-pack mode, roles | profile, config |
| Harness | The agent runtime executing the skills: Cursor or Claude Code | platform, client |
| Adapter | An execution backend for workers, `native` or `herdr` | runner |

## Reserved ID prefixes

One prefix per record type. A run never introduces a second scheme.

| Prefix | Record | Example |
| --- | --- | --- |
| `FR-` | Frontier item | `FR-resolve-page-place` |
| `MODEL-`, `CONTRACT-`, `STATE-`, `BEHAVIOR-` | Requirement, by type | `CONTRACT-find-sale-comps` |
| `PRF-` | PRD review finding | `PRF-003` |
| `PT-` | Ponytail finding | `PT-007` |
| `D-` | Decision | `D-012` |
| `Q-` | Open question | `Q-export-formats` |
| `HR-` | Human review record | `HR-004` |
| `RA-` | Realignment | `RA-002` |
| `INV-` | Invalidation | `INV-005` |
| `DISC-` | Discovery report | `DISC-backend` |
| `PR-` | Pull request and its packet, build, and review | `PR-02` |

## Status vocabularies

| Record | Allowed values |
| --- | --- |
| `run.md` status | `active`, `awaiting-human-review`, `realigning`, `blocked`, `parked`, `pivoted`, `abandoned`, `completed`, `failed` |
| Artifact index status | `complete`, `accepted`, `approved`, `invalidated`, `superseded`, `blocked` |
| Human review decision | `approved`, `changes-requested`, `rejected` |
| Worker outcome | `complete`, `clarification-required`, `changes-required`, `blocked` |
| Ponytail outcome | `accepted`, `changes-required`, `blocked` |
| Unit state | `planned`, `ready`, `building`, `in-review`, `repairing`, `accepted`, `merged`, `abandoned`, `blocked` |
| Published `Status:` line | `planned`, `in-progress`, `shipped`, `pivoted`, `abandoned` |
| Glossary term status | `existing`, `new`, `renamed`, `retired` |
| Realignment class | `rename-only`, `requirement`, `contract-model-state-behavior-design`, `sequencing`, `scope` |
| Realignment impact | `none`, `label-refresh`, `revalidate`, `regenerate` |
| Existing-build proposal | `keep`, `rebase`, `replace`, `cancel` |

Any other word is a defect the orchestrator rejects before a checkpoint.
