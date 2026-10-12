---
name: product-spec
description: Interviews a product owner and iterates an approved product requirements document using the target repository's durable product context, starting from the shape of the deliverable and keeping terms and question IDs stable across drafts.
---

# Product Spec

Create or revise a product requirements document without implementing software.
This is the product-discovery mode for Lore Flow. It ends with an
explicitly approved PRD that can be passed to `orchestrate-feature`.

## Inputs

Require:

- target repository path
- product idea, requested change, or existing PRD to revise

Accept an optional PRD slug, desired output path, product context root, and human
decisions already made. The target repository must be a Git repository.

## Product context

Use `product/` as the durable product context directory unless the repository keeps it
elsewhere; record the root you used in `approval-record.md`. Before asking questions,
inspect:

- `product/CURRENT_PRODUCT_STATE.md`
- `product/PERSONAS.md`
- `product/GLOSSARY.md`
- existing files under `product/` and `docs/` that are clearly product or PRD
  documents

If the first three files do not exist, create them from the templates in
`templates/product/`. Do not replace an existing file or silently rewrite
unconfirmed product facts. If a context file is missing information, record
the gap and ask about it.

`CURRENT_PRODUCT_STATE.md` is the baseline of what is true now. It must not be
rewritten to describe proposed behavior. A proposed change belongs in the PRD.
Update current state only when the human explicitly confirms that the product
has changed.

## Interview loop

Run a focused interview in rounds. Ask only the highest-value unanswered
questions, grouped so the human can answer efficiently. Use existing product
context and reasonable defaults; label assumptions instead of presenting them
as facts.

Round one always settles the shape of the deliverable before anything else: is this
PRD a set of user-visible components, a set of user journeys, or parity with existing
cases? Write five one-line candidate stories in that shape and ask the human to confirm
them. Every later draft keeps that shape; a change of shape is a new PRD, not a new
draft.

Every question states in one clause why the repository, product context, or earlier
answers cannot answer it. A question that the context can answer is not asked. When a
human answer enumerates a list, confirm in the same round whether items present in the
current draft but absent from the answer are dropped or kept; never open a new round for
that. Do not ask the human to choose a transport, component framework, or other
implementation detail.

Cover, as applicable:

- problem, target users, and user context
- desired outcome and measurable success
- primary journey and important alternate or failure paths
- scope and explicit non-goals
- roles, permissions, and data boundaries
- accessibility, device, localization, and operational needs
- constraints, dependencies, risks, and rollout expectations
- acceptance criteria and definition of done

After each answer round:

1. Edit only the changed sections of `product/prds/<feature-slug>.md` and the
   product context files in place; do not rewrite whole files.
2. Rewrite the draft's `## Changed in this draft` block: Added, Changed, and Removed,
   each naming the section. Removed may not be empty when a requirement, acceptance
   criterion, or story disappeared.
3. Commit only those files as `prd(<feature-slug>): draft v<n>`. The commit is the
   draft version; do not copy drafts elsewhere. When `product/` is excluded from Git in
   this repository, record the file's SHA-256 in `approval-record.md` instead.
4. Append the round's resolved decisions to `interview-decisions.md`, each naming the
   PRD section it changed.
5. Check the draft against the glossary: every capitalized noun phrase in the output
   tables, user stories, and functional requirements has a glossary row; a term that
   replaces a glossary term gets a row with the old term under Avoid. Personas come
   from `PERSONAS.md`; a story may not introduce a new actor.
6. Ask the next smallest set of questions that materially affects product
   behavior.

Do not start technical discovery, choose an implementation, or launch builders.
Escalate product choices rather than resolving them as technical details.

## PRD shape

Write the draft using this structure:

```md
# Product Spec: <name>

## Changed in this draft
## Terms
## Problem
## Today
## Users and context
## Desired outcome and success measures
## User stories
## Primary journey
## In scope
## Out of scope
## Functional requirements
## UX and accessibility requirements
## Data, permissions, and operational requirements
## Constraints and dependencies
## Risks and open questions
## Acceptance criteria
## Definition of done
```

`## Terms` lists the glossary rows this PRD introduces or relies on. `## Today` is three
to five lines pulled from `CURRENT_PRODUCT_STATE.md` with a link. Open questions carry
stable `Q-<slug>` IDs and acceptance criteria carry stable `AC-<slug>` IDs; a resolved
question is marked resolved and a dropped criterion is listed under Removed, never
renumbered. Constraints name each referenced ticket with its title on first mention.

Requirements and acceptance criteria must describe observable product behavior.
Use the glossary's canonical terms and identify conflicts with existing
personas or current state.

## Review and approval loop

Before requesting approval, and again for every draft that changes scope, review the
draft for:

- a clear problem and user
- necessary and sufficient scope
- explicit non-goals
- coherent journeys and failure behavior
- testable acceptance criteria
- accessibility and permission implications
- unresolved product decisions
- requirements removed since the last draft, each with a recorded decision
- contradictions with current state, personas, or glossary

Record the review for that draft in `review-findings.md`; a draft with no entry may not
be approved.

If material gaps remain, return to the interview. Do not ask for approval of a
PRD containing unresolved choices that would change product behavior.

Present the exact draft path, version, commit or hash, the `Changed in this draft`
block, and a short change summary. Pause for explicit human approval. An approval must
name the PRD version or exact file contents; silence, an edited file, or a
conversational "looks good" without identifying the artifact is not approval.

If the human requests changes, record the feedback and resulting decisions,
revise only the affected sections, commit the next draft, and repeat review and
approval. A version after an approved one opens its `Changed in this draft` block with
`since approved v<n>`. Git history preserves every prior draft. Never amend or rewrite
an approved commit.

Keep approval status out of the PRD file so the approved commit stays byte-for-byte
the approved text.

## Outputs

Create or update:

- `product/prds/<feature-slug>.md` as the approved PRD, committed once per draft
- `product/GLOSSARY.md` rows the PRD introduced
- `.lore-flow/product-specs/<run-id>/` as ignored run evidence with only:
  - `interview-decisions.md`: decisions appended per round
  - `review-findings.md`: one entry per reviewed draft
  - `approval-record.md`: context root, status, approved version, approved commit or
    hash, and the review findings that cleared it

The final report must state one of:

- `approved` — exact PRD path, version, and commit or hash approved
- `awaiting-human-review` — exact draft and approval action required
- `clarification-required` — the smallest unanswered product decisions
- `blocked` — missing repository access or required context

After approval, hand `path@commit` to `orchestrate-feature`; do not invoke it
automatically unless the human explicitly requests implementation.
