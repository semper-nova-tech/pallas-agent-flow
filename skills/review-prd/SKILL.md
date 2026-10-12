---
name: review-prd
description: Reviews a product requirements document to define the current-to-requested behavior frontier, expose ambiguity, seed the feature glossary, and produce evidence-backed approval checkpoints. Use before technical discovery or implementation planning.
---

# Review PRD

Define what the product does now, what the PRD asks it to do, and the exact frontier
between them. Review product intent; do not design the implementation.

## Inputs

- PRD path or authoritative source
- target repository path
- run artifact root and feature glossary path
- known decisions and constraints

Inspect repository evidence only as needed to verify claims about current behavior.
Label unsupported claims rather than filling gaps from intuition.
Apply the orchestrator human-readable output policy to every created item and artifact.

## Review

1. Extract actors, triggers, outcomes, acceptance criteria, exclusions, and rollout needs.
2. Record current behavior with repository or product evidence.
3. Record requested behavior with citations to the PRD.
4. Define frontier items (`FR-<slug>`): the smallest observable differences between
   current and requested behavior.
5. Add a glossary row for every domain noun and verb the PRD relies on that has no row
   yet, with meaning only; mark it `new`. Reuse an `existing` row when discovery already
   named the concept, and record the PRD's wording as an alias when it differs.
6. Find contradictions, ambiguous terms, missing edge cases, and unowned decisions.
7. Separate product requirements from suggested implementation. Flag any PRD text that
   prescribes a transport, vendor, library, or protocol as a design assumption and hand
   it to discovery as a question: how does the repository already reach this system?
8. Decide whether technical discovery may proceed.

Challenge:

- implied actors, permissions, data ownership, and error behavior
- unclear source of truth or lifecycle
- missing empty, loading, failure, retry, and concurrency behavior
- unstated compatibility, migration, telemetry, or rollout expectations
- acceptance criteria that cannot be observed or tested
- requirements that conflict with explicit non-goals
- two PRD terms that mean one thing, or one term used for two things

## Output contract

Write `prd-reviews/<feature-slug>.md` under the run root. The published technical spec
is minted later from this review; do not ask reviewers to open the run file.

```markdown
# PRD Review
Status: complete | clarification-required | blocked

## Executive summary
## Sources and evidence
## Current behavior
## Requested behavior
## Frontier
- [Frontier name] (FR-<slug>): [plain-language meaning]
  - Today:
  - After:
  - Evidence:
  - Acceptance observation:
## Terms added or reused
## In scope
## Out of scope
## Ambiguities and contradictions
## Design assumptions in the PRD
## Product decisions required
## Discovery questions
## Open questions
## Approval checkpoint
```

Findings use `PRF-<nnn>`. Open questions use stable `Q-<slug>` IDs that survive every
later version; a resolved question is marked resolved, never renumbered. Every frontier
item must be independently observable and cite both sides when current behavior exists.
Use `unknown` when evidence is absent.

## Approval checkpoint rules

Return `complete` only when:

- each requested behavior maps to a frontier item or explicit non-goal
- acceptance is observable
- no critical contradiction remains
- every domain term in the frontier has a glossary row
- open questions can be resolved technically without changing product intent

Return `clarification-required` when a product choice materially changes behavior,
scope, security, persistence, or user experience. Ask the smallest answerable questions.
Return `blocked` when the source is unavailable or internally irreconcilable.

Return to the orchestrator only a short status, frontier summary, glossary rows added,
decision requests, and artifact path. Do not forward source text or a transcript. Do not
ask the human to accept the review; the orchestrator owns every approval checkpoint.
