# Pallas Agent Flow retrospective: five runs, 2026-09-30 to 2026-10-09

Scope: every `.pallas-agent-flow` tree on this machine, all produced by plugin 0.4.0 (commit `82abc3a`), compared against plugin HEAD `6d1ac29`.

| Run | Where | Outcome | What happened |
| --- | --- | --- | --- |
| AIA-159 Multi-specialist replies | `projects/web/.pallas-agent-flow/runs/aia-159-20261001` | 4 PRs merged | 17 recorded human reviews, 3 realignments, 5 requirement versions, 5 writer-spec versions. Findings mechanism shipped in PR-3 was replaced within days. |
| AIA-160 Market context agent | `projects/web/.pallas-agent-flow/runs/2026-09-30-aia-160-market-context` | 2 of 3 PRs merged, run idle | PR 1 built, reviewed, pushed, then redesigned from scratch. Two live `01-*` packets. PR 3 never started. No final report. |
| AIA-220 Know which place | `~/.herdr/worktrees/web/aia-220-resolve-place-representations` | Blocked at spec approval | Reviewer answered the checkpoint with a new architecture constraint (go through the AIA-222 MCP). Nothing built. Index still says "accepted". |
| AIA-222 Sale and lease comps | `~/.herdr/worktrees/web/aia-222-find-sale-comps` + 3 hand-made worktrees | Pivoted | Spec approved 3 times, Ponytail 5 rounds, PR1 built then closed unmerged, unplanned LangChain upgrade PR, hand-written PR4 reworked 4 times. PR2/PR3 never built. |
| Research AI integration (product-spec) | `~/.herdr/worktrees/web/develop/.pallas-agent-flow/product-specs/2026-10-07-research-ai-integration` | Approved twice | v4 approved, stories rejected, v5 rewrote 60% of the body and silently dropped requirements, approved again. |

## Part 1. What went wrong, across runs

Ranked by how often it recurred and how much human time it cost.

### 1. Run state stops tracking reality after the first human redirect (4 of 4 orchestration runs)

- AIA-160 `run.md:11` says "PR 2 merged" while `run.md:40` says "PR 1 pushed; PR 2 … after PR 1 merges". `artifact-index.md` frozen at the abandoned seam design; no rows for pkt-01 v3, req v4, PR 2 build.
- AIA-222 `run.md` status `awaiting-merge` (not a schema value), `current-phase: 3 — build PR1` after PR1 was closed, last line "Next: PR2 build waits for #19314" two hours after #19314 closed. `invalidations.md` records 1 of 4 realignments.
- AIA-220 `run.md:11` `decisions: none yet` with seven decisions on disk; index says packets "accepted by Ponytail" after D7 invalidated them.
- AIA-159 `artifact-index.md` missing HR-013, HR-016, HR-017 and three amendment builds.

Root cause: `run.md` and the index are append-only logs with no regenerated "where things stand" view, no terminal statuses for parked or pivoted runs, and no consistency check before a checkpoint.

### 2. Human changes bypass `realign-run` (every run)

- AIA-160: three material realignments (seam → new lib, validators return `fault`, PR-2 prompt behavior) recorded only as prose in `decisions/product-decisions.md:19-24`. No `realignments/`, no `invalidations.md`.
- AIA-220: checkpoint answered with D7, recorded as `Decision: not given` in `human-reviews/approve-technical-specs.md:4`.
- AIA-222: `approve-technical-spec.md:6` "approved, with follow-up answers that change PR 1's contract". Approval-with-changes recorded as approval. PR4 redesigned four times against packet v1.
- AIA-159: three realignments did run, but REQ v5 was mutated after acceptance to add F-08 with no v6 (`requirements/multi-specialist-replies.md:3` vs `:132`).

Root cause: the skills describe realignment but never say what *triggers* it. Any checkpoint reply that is not one of the three decisions, any PR-review commit that renames an exported symbol, any mid-build "actually do X" should route through it. Today none do.

### 3. Versions are overwritten and no artifact says what changed (every run)

- AIA-220: requirements v1, PR02/03 v1, discovery v1 gone, overwritten in place. Ponytail v2 is three lines: "B1-B4 and N1-N4 all resolved".
- AIA-222: `requirements/sale-lease-comps.md:1` says v4, `:6` says v3; index rows 14 and 34 disagree on where v2 lives; `01-…-packet.v2.md` puts the version in the filename.
- AIA-160: `pkt-01` denotes two unrelated designs; pkt-02 v2 never existed; pkt-03 is "v2.1".
- AIA-159: REQ v2 and v3 say "as v1" in most cells, then v4 had to restore everything.
- Product-spec: v4 → v5 dropped the "untrusted output" security rule, typed failures, and context-ID binding with no record in `decisions.md` or `review-findings.md` (which skipped v3 and v5 entirely).

The only good patterns in 5 runs: AIA-160 pkt-02 v3 line 6 "Supersedes pkt-02 v1. What changed: …" and the AIA-159 writer-spec "Changes from vN" header. Nothing in the plugin requires them.

### 4. Naming has no spine (every run)

No run created a glossary. `templates/product/GLOSSARY.md` is wired only into `product-spec`. `aliases.md` was created in 1 of 4 runs (AIA-160) and only for branch names.

One feature, many names:

| Run | Names in use |
| --- | --- |
| AIA-220 | "Know which place I'm asking about" (ticket) / `know-which-place` (slug) / `place-resolution` (run-id) / `resolve-place-representations` (branch) / three planned `aia-220-*` PR branches |
| AIA-222 | "Sale and lease comps" / `sale-lease-comps` / `find-sale-comps` (worktree, named after the old tool) / "data platform MCP tools on the property and search agents" (PR4) |
| AIA-160 | PR 1 has six names: "Inject the posts compressor", "Posts compressor injection", "market-context-ai-tools util lib (stage 1)", "PR 1 v3", "Market-context AI tools, stage 1", `pkt-01` |
| AIA-159 | What a subagent returns: note → `SpecialistNote` → "agent findings" → `DelegateNodeResult`. The actor: specialist / subagent / delegate / agent in one paragraph (`builds/PR-4.md:2`) |

ID collisions: AIA-159 `F-001…F-012` (PRD findings) vs `F-01…F-08` (fan-out requirements), both abbreviated "F-0n"; AIA-220 `D5`/`D6` mean different things in `prd-reviews/` and `decisions/`. Twelve ID prefixes in one run. Eight status words in use against five allowed.

Code renames never flow back: sender → connection (AIA-222 `run.md:73`, packet and build report still say Sender), `bindDataPlatformMcpTools` → `getDataPlatformMcpTools`, notes → findings (PR-2 merged title still says "specialist notes"). AIA-159 RA-002's alias table was copied with both sides already renamed: "`DelegateNodeResult` → `DelegateNodeResult`".

Concept substitution hidden as rename: AIA-222 `find_lease_comps` → `search_lease_listings`. Lease *comps* became lease *listings*, and the radius-anchored search (FR-3) was dropped. No glossary meant nobody noticed the noun changed.

### 5. Discovery misses what already exists, and that causes the biggest reversals (4 of 4)

- AIA-159: designed custom `STEP_*` events when AG-UI already had `SUBAGENT_*`; designed frontend-call replay when `bindFrontendTools` existed in a lib discovery had mapped; Bedrock `tool_choice` constraint found in-build.
- AIA-160: PRD prescribed Gateway + MCP; discovery never surfaced in-repo `llmCall` + Nova. User stripped MCP, Gateway and the exclude list in round 2, then rejected the whole PR 1 design after build + push.
- AIA-222: discovery concluded "No GraphQL library in repo; use plain `fetch`"; the MCP server arrived from the human at approval; `@langchain/*` versions appear nowhere in planning; auth audience mismatch found at `run.md:88`; 401 on `initialize` found at build.
- AIA-220: run blocked because the MCP from AIA-222 was coming; D5 "network access" was marked `assumed` and never verified.

The user's own memory rules (use existing protocols, reuse over rewrite, bind MCP tools at invocation) are all corrections for the same gap. `discover-stack` lists "existing patterns closest to each frontier item" but never requires an inventory of exported symbols, installed protocol versions, or how the repo already reaches the target system.

### 6. Ponytail drifts into lint and misses the killer assumption (3 of 4)

- AIA-220: all four blocking findings were Nx `package.json` dependency hygiene. None challenged direct OpenSearch access, the assumption that ended the run.
- AIA-160: cross-team file mutation flagged non-blocking (`reviews/ponytail-pre-build.md:8`). The user rejected the design after build.
- AIA-159: ran once pre-build on v3, never on v5, never post-build. User hand-trimmed PR-4 by 618 lines.
- AIA-220 and AIA-222 reviews omit the required headings (Rejected concerns, Requirement trace, Minimality verdict).

### 7. The plugin has three sources of truth for paths and IDs (plugin defect)

| Source | Says |
| --- | --- |
| `config/presets.json` role `output` | `builds/<pr-id>.md`, `discovery/frontend.md`, `prd-review.md`, `requirements.md`, `pr-sequence.md`, `final-report.md` |
| `agents/claude/*.md` | `builds/<pr-id>.md`, `ponytail-pre-build.md`, `reviews/<pr-id>-ponytail.md`, `realignments/<realignment-id>.md` |
| `run-schema.md` | `pull-requests/<nn>-<domain>-<purpose>-{packet,build,review}.md`, `discovery/<slug>-<area>.md`, `prd-reviews/<slug>.md`, `reports/<slug>-final.md` |

Result: four runs, four layouts (`builds/` + `sequences/` + `product-specs/`; `published/` + `superseded/` + `source/`; `pull-requests/` + `reports/`). Three run-id formats (`aia-159-20261001`, `2026-09-30-aia-160-market-context`, `20261008-aia-220-place-resolution`). `gate` appears 17 times in plugin text although `human-readable-output.md:22` bans it.

### 8. Phase collapse: packets minted at planning (3 of 4)

`orchestrate-feature/SKILL.md` step 1 says "`plan-requirements` emits one technical-spec packet per independent implementation unit". AIA-220's planner produced PR packets, so Ponytail "pre-build" reviewed packets and the sequence checkpoint never existed. AIA-222 wrote `pull-requests/index.md` with a DAG at planning. AIA-159 used sequence sections as packets with no non-goals or acceptance checks.

### 9. Published pack policy collides with repo norms (3 of 4)

AIA-222 committed the pack then deleted it (`7b2af21bffa`) and the `.gitignore` entry at the user's request; the only post-adapter docs were in the deleted commit. AIA-160 never created one. AIA-220 is excluded via `.git/info/exclude`. Published docs in all three now describe features that were not built, with no `Status:` line saying so.

### 10. Builders lack access and manifests (3 of 4)

AIA-159: builders could not write `.pallas-agent-flow/`, reports pasted by the parent, `guidance/` empty across seven builds. AIA-222: planner verified the live schema via MCP; builder guessed operator names; orchestrator amended post-build. AIA-160: manifests hashed untracked local files and two builders claimed to have applied them.

### 11. Product-spec: the shape question came last

v1 to v4 never asked whether the deliverable was user-visible components or eval parity; the story pass broke it and forced v5. Wasted questions: `recall` (discoverable), DOCX (already in v1), AG-UI transport (implementation). Open-question and AC numbers reset every draft, so `review-findings.md` and the rejected stories cite numbers that no longer exist. Glossary created at 12:30, never touched; v5 introduced *brief*, *CSV artifact*, *verdict card*, *metric cards* (three names for one thing) and switched persona from "broker" to "user" with no record.

### What HEAD `6d1ac29` already fixed

Single-table index, no run-folder copies of published docs, workers never talk to the human, preset recorded in `run.md`, product-spec drafts versioned as commits with status kept out of the file. None of items 1 to 11 above are addressed.

## Part 2. Proposals

Ordered so each builds on the last. Each names the file to change.

### A. One naming contract for the plugin itself

1. Make `run-schema.md` the only path authority. Remove `output` from every role in `config/presets.json`. Rewrite `agents/claude/*.md` and `agents/cursor/*.md` to say "write the path the packet assigns" and nothing else.
2. Fix the run-id: `<yyyy-mm-dd>-<ticket>-<feature-slug>`. Fix the feature slug rule: derived from the ticket title, at most four words, verb-first when the ticket is a behavior.
3. Add a `names` block to `run.md`, written at intake and never edited without an alias row:

```md
## Names
- Ticket: AIA-222 "Sale and lease comps"
- Feature slug: sale-lease-comps
- Working branch: aia-222
- Published pack: docs/features/sale-lease-comps/
```

4. Replace `gate` with `approval checkpoint` everywhere in plugin text. Add a `docs/glossary.md` to the plugin defining its own terms once: frontier, requirement, packet, PR note, unit, checkpoint, realignment, alias, invalidation, published pack, run machinery.
5. Reserve ID prefixes in `run-schema.md` so no two artifact types share one: `FR-` frontier, `RQ-` requirement, `PRF-` PRD finding, `PT-` Ponytail finding, `D-` decision, `Q-` open question, `HR-` human review, `RA-` realignment, `PR-` pull request. Forbid a second scheme inside a run.
6. Enforce the status vocabulary. `run.md` status gains `parked`, `pivoted`, `abandoned`. Index status stays at five words. The orchestrator rejects any other word.

### B. A run glossary and a naming review step

7. `orchestrate-feature` creates `glossary.md` in the run root at setup, seeded from `templates/product/GLOSSARY.md`. `review-prd` fills it with every domain noun in the PRD (comp, listing, record, anchor, specialist, finding). The published `README.md` gets a `## Terms` section that is a copy of the glossary rows the feature uses.
8. `plan-requirements` adds a **Proposed names** table to the technical spec: symbol, file, meaning, and the glossary term it implements. This is where humans rename, not in code review.
9. `sequence-prs` adds each PR's display name to the glossary. One display name per PR; the packet title, index row, PR note, branch, and GitHub PR title all use it verbatim.
10. Add a **naming review** to Ponytail pre-build with a checklist: every noun in a requirement is in the glossary; no two glossary rows mean the same thing; display names are verb-first for behaviors and noun-first for models; no symbol in the Proposed names table collides with an existing export; no name has an abbreviation the glossary does not define (the AIA-159 `W` case).
11. `aliases.md` is created non-empty at setup (the names block above). Every rename, in any artifact or in code review, adds a row before the renamed artifact is touched. `realign-run` classifies a rename whose noun is not in the glossary as `scope`, never `rename-only`. This would have caught lease comps → lease listings.
12. `final-report` reconciles every row of the Proposed names table against `git` exports and lists the mismatches.

### C. Every version says what changed

13. Any artifact at v2 or later opens with a fixed section:

```md
## Changed since v1
- Added: …
- Changed: … (section)
- Removed: … (section, reason, decision)
```

Removed is mandatory and may not be empty when a requirement, acceptance criterion, or story disappeared. Apply to requirements, packets, published docs, PRD drafts, and Ponytail re-reviews. A Ponytail re-review that says only "resolved" is rejected.
14. Accepted versions are immutable: `realign-run` always emits v(n+1) as a new file and the old one moves to `superseded/` in the same step. Integer versions only. No version in a filename, no version header in the body; the index is the sole version source.
15. A replaced design gets a new packet ID and a new display name. Same ID means same intent.

### D. Today, after, and how you will see it

16. Technical spec template: every requirement gains two lines, `Today:` and `After:`, each one sentence. The PRD review already produces current and requested behavior; carry it through instead of leaving it in the gitignored folder.
17. Architecture overview: the "current-to-end-state delta" becomes a required first section with the fixed heading `## Today → After`. AIA-222's published overview is the model; AIA-220's has none.
18. Published README and technical spec gain a `Status:` line (`planned`, `in progress`, `shipped`, `pivoted`, `abandoned`) that realignment must rewrite.
19. Build report and PR note open with a five-line block before anything else:

```md
Before: the market agent validates places with validate_location against OpenSearch.
After: both agents call resolve_place_representations through the data platform MCP.
See it: ask "comps near 123 Main St" in the sales chat; the tool card names the resolved place.
Files: 7 changed in libs/crexi-ai/backend/feature/market-context-agent
Checks: pnpm nx test market-context-agent — pass
```

Drop boilerplate lines ("Approved diagrams delivered: none were assigned") when the value is none.
20. Build reports are one file per attempt. A redesign writes a new build file; the previous one is collapsed to one line in a "Prior attempts" list. AIA-222's 500-line `04-…-build.md` with "Redesign 1-4" is the failure case.

### E. Run state that a human can read in ten seconds

21. `run.md` gets a regenerated table, rewritten at every checkpoint and every unit state change:

```md
## Where things stand
| Unit | Branch | PR | Packet | State | Next |
| --- | --- | --- | --- | --- | --- |
| Data platform client | aia-222-crexi-data-platform-client | #19314 closed | v3 | abandoned | none; kept for benchmarking |
| MCP tools on agents | aia-222-property-agent-data-platform-tools | #19354 open | v1 | in review | address review |
```

22. Add a consistency check the orchestrator runs before every approval request and before final report: every path in the index and README exists; every version named in a human review has an index row; status words are valid; no two live files share a sequence number; every packet references a manifest that exists. Failures block the checkpoint.
23. Human review records: one file per review, named `<action>-<subject>.md`. AIA-159 put 17 reviews in `approve-prd-aia-159.md`.
24. `final-report` runs on every terminal state, including `parked`, `pivoted`, and `abandoned`, and must say where the accurate end-state description now lives.

### F. Realignment triggers, written down

25. In `orchestrate-feature/SKILL.md` approval rules, add: a checkpoint reply is `approved`, `changes-requested`, or `rejected`. Anything else, including an approval that carries answers which change a contract, path, owner, or dependency, is recorded as `changes-requested` and routed to `realign-run`.
26. During a build, any instruction that changes the unit's contract pauses the builder, emits packet v(n+1) through `realign-run`, and restarts from the packet. After two redesigns of one unit the run returns to the requirements checkpoint.
27. Post-merge, Ponytail post-build diffs the packet's "contracts exposed" against the actual exports. Each mismatch needs an alias row or a realignment.
28. Guidance manifests may list only `git ls-files`-tracked paths. A builder records the hash it read; a missing file is `skipped`, never "applied".

### G. Discovery that finds what already exists

29. `discover-stack` output gains three required sections:
    - **Existing capabilities**: exported symbols of every lib in scope, with one-line meaning.
    - **Installed protocols and SDKs**: package, version, and the events, schemas, or tools it already provides that touch the frontier.
    - **Integrations**: how the repo already reaches each external system named in the PRD, the auth mode and audience, and the installed client.
30. `plan-requirements` lists "facts to verify before build" with an owner and the checkpoint where each is checked. A packet may not name a dependency discovery did not observe.
31. `review-prd` flags PRD text that prescribes a transport, vendor, or library as a design assumption and sends it to discovery as a question.

### H. Ponytail aimed at assumptions, not lint

32. Pre-build checklist adds: name the single assumption whose failure invalidates the most requirements, and give a verdict on every decision marked `assumed`.
33. Block when a packet mutates a file owned by another team or domain and an additive in-domain alternative exists.
34. Block when a packet mixes areas, or lacks a required field from `context-packets.md`.
35. The orchestrator rejects a review file missing the template headings.

### I. Phase boundaries and builder access

36. Reword `orchestrate-feature` step 1 to "emits one named requirement set". `plan-requirements` may not write under `pull-requests/`. Packets come only from `sequence-prs`.
37. Build packets gain a **Verification access** field listing the MCP servers and commands the builder may call. Builder agent definitions get the same MCP allowlist as the orchestrator for the target system. Builders get write access to `pull-requests/` in the run root.
38. Preset option `published-pack: committed | local | none` resolved at run setup and recorded in `run.md`. When `local`, builders refresh the planning worktree copy, never a build worktree copy.

### J. Product-spec

39. Round 1 asks the shape question: user-visible components, journeys, or parity cases. Require a five-line dry-run story list before the first approval request.
40. Each question states why the repo or product context cannot answer it. When a human answer enumerates a list, confirm omissions against the current draft in the same round.
41. Open questions and acceptance criteria carry stable slugs (`Q-export-formats`, `AC-citation-hover`). Resolved items are marked, never renumbered.
42. PRD gains `## Today` after `## Problem`, three to five lines pulled from `CURRENT_PRODUCT_STATE.md` with a link, and `## Terms` first, listing the terms this PRD introduces with glossary rows.
43. Every draft that changes scope gets a review entry. The pre-approval review checks "removed requirements" explicitly.
44. State what to do when `product/` is git-excluded (this repo): record `sha256` in `approval-record.md` instead of a commit.

## Part 3. Suggested order

1. A (plugin naming contract) and E (run state table + consistency check). Cheap, mechanical, and every other fix depends on the orchestrator being able to tell what is current.
2. C (changed-since) and D (today/after). Pure template changes.
3. B (glossary and naming review) and F (realignment triggers).
4. G and H (discovery inventory, Ponytail aimed at assumptions). These remove the cause of the largest reversals.
5. I and J.
