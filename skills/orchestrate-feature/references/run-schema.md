# Pallas Agent Flow Run Schema

Use human-readable Markdown. Apply [human-readable-output.md](human-readable-output.md)
to every record and path. Names, ID prefixes, and status words come from the plugin
[glossary](../../../docs/glossary.md); any other word is a defect.

## Run identity

- `run-id`: `<yyyy-mm-dd>-<ticket>-<feature-slug>`, for example
  `2026-10-08-aia-222-sale-lease-comps`.
- `feature-slug`: lowercase, hyphenated, at most four words, derived from the ticket
  title. A behavior ticket gets a verb-first slug (`resolve-page-place`); a thing gets a
  noun slug (`sale-lease-comps`). The same slug names the published pack and every
  per-feature artifact.
- The run root is `.pallas-agent-flow/runs/<run-id>/` in the target repository, recorded as an
  absolute path so workers in other worktrees can write to it.

## Run manifest

Create `run.md` with these sections in this order.

### Header fields

- `run-id`, `status`, `target-repository` (absolute path), `run-root` (absolute path)
- `prd-source`: `path@commit` or the authoritative reference
- `preset`: selected key plus its resolved harness, approval checkpoints, published-pack
  mode, and role/model mappings
- `harness` and `adapter`
- `started-at` and `updated-at` as ISO-8601 timestamps
- `current-phase`: one of `intake`, `technical-specs`, `spec-review`, `sequencing`,
  `building`, `recovery`, `reporting`, `closed`
- `pending-approval`: checkpoint name, reviewer, and exact artifact versions, or `none`

`status` is one of `active`, `awaiting-human-review`, `realigning`, `blocked`,
`parked`, `pivoted`, `abandoned`, `completed`, `failed`. The last five are terminal and
each requires a final report.

### Names

Written at intake and changed only through an alias row:

```md
## Names
- Ticket: AIA-222 "Sale and lease comps"
- Feature slug: sale-lease-comps
- Working branch: aia-222
- Published pack: docs/features/sale-lease-comps/
- Glossary: docs/features/sale-lease-comps/glossary.md
```

### Where things stand

A table regenerated, not appended, at every checkpoint and every unit state change. A
reader learns the current state of every unit from this table alone.

```md
## Where things stand
| Unit | Branch | PR | Packet | State | Next |
| --- | --- | --- | --- | --- | --- |
| Data platform client (PR-01) | aia-222-data-platform-client | #19314 closed | v3 | abandoned | none; kept for benchmarking |
| MCP tools on agents (PR-02) | aia-222-mcp-tools | #19354 open | v1 | in-review | address review comments |
```

Unit state is one of `planned`, `ready`, `building`, `in-review`, `repairing`,
`accepted`, `merged`, `abandoned`, `blocked`.

### Constraints, decisions, blockers

- `constraints`: one bullet per constraint with its source (user, repository file, preset)
- `decisions`: numbered, in the form `Name (D-nnn) — one sentence. Consequence: …`.
  A superseded decision stays listed, struck through, with the decision that replaced it.
- `blockers`: name, owner, and the smallest action that clears it

Do not store secrets, credentials, or full transcripts. Do not append logs here; the
build report and human review records hold detail.

## Artifact index

Create `artifact-index.md` as one Markdown table, one row per artifact version. The index
is the only source of version numbers; artifacts carry no version in their filename or
body header.

| Name | Path | ID | Version | Predecessor | Status | Producer | Inputs |
| --- | --- | --- | --- | --- | --- | --- | --- |

- **Path** is relative to the run root, or repository-relative for published files.
- **Version** is an integer `v<n>` for run artifacts and the Git blob hash
  (`git hash-object <path>`) for published files. Never copy a published file into the
  run folder to version it. When the published pack is `local`, record the SHA-256
  instead of a blob hash.
- **Status** is `complete`, `accepted`, `approved`, `invalidated`, `superseded`, or
  `blocked`.

Add a row in the same step that writes the artifact.

## Versions are immutable

- An accepted version is never edited. A change produces `v<n+1>` as a new file at the
  readable path; the prior version moves to `superseded/<readable-path-without-ext>/v<n>.md`
  in the same step.
- Every `v2` or later artifact opens with a `## Changed since v<n-1>` section listing
  Added, Changed, and Removed items, each naming the section it touched. Removed may not
  be empty when a requirement, acceptance check, story, or PR disappeared.
- A replaced design gets a new ID and a new display name. The same ID always means the
  same intent.
- Mark the prior version `superseded` only after its replacement is accepted. Record
  `superseded-by`, the reason, and the approving review in the index row.
- Any artifact that an invalidation reaches is marked `invalidated` until a replacement
  is accepted.

## Glossary and aliases

- `glossary.md` is the feature glossary in the published pack
  (`docs/features/<feature-slug>/glossary.md`), created at intake from
  `templates/feature/glossary.md`. The index records its blob hash like any published
  file. When the published pack is `none`, the glossary lives at the run root instead.
- `aliases.md` at the run root is created at intake with the Names block as its first
  rows. Every rename of a term, symbol, path, branch, requirement, decision, or PR adds a
  row: stable ID, old name, new name, surface, reason, review ID, and timestamp before
  any artifact uses the new name.
- A row whose old and new names are equal is a defect.

## Human review records

One file per checkpoint decision under `human-reviews/<action>-<subject-slug>.md`.
Record:

- display name, plain-language purpose, review ID (`HR-`), and checkpoint name
- reviewer identity, ISO-8601 timestamp, and comments
- decision: `approved`, `changes-requested`, or `rejected`, and nothing else
- reviewed artifact names with exact IDs and versions
- policy or preset that required the checkpoint
- resulting status, decision IDs, and realignment ID when applicable

Approval applies only to the listed versions. An approval whose comments change a
contract, path, owner, dependency, or protocol is recorded as `changes-requested` and
routed to `realign-run`; the run does not proceed as if approved.

The mandatory checkpoints are Technical requirements and PR sequence. Per-PR approval
before each build is on by default and uses the same record shape; disable it only with
`each-pr: false`.

## Realignment and traceability

Maintain:

- `aliases.md` as above
- `invalidations.md`: changed source version, classification, dependency path, impact,
  affected version, proposed action, and disposition. One row per reachable artifact
  per realignment, including "on hold", "closed without merge", and "replaced by unit N".
- `realignments/<change-slug>.md`: changed artifacts, transitive impact, minimal rerun,
  preserved artifacts, implementation proposals, approvals, and next checkpoint

Change classification is `rename-only`, `requirement`,
`contract-model-state-behavior-design`, `sequencing`, or `scope`. A change to a term's
meaning is never `rename-only`. Impact is `none`, `label-refresh`, `revalidate`, or
`regenerate`. Keep unaffected accepted artifacts accepted and retain all prior review and
decision history.

## Readable artifact layout

Use lowercase purpose slugs:

- `prd-reviews/<feature-slug>.md`
- `discovery/<feature-slug>-<area>.md` and `discovery-index.md`
- `architecture/<feature-slug>-<domain>.md` when a domain draft is needed
- `decisions/<decision-slug>.md`
- `human-reviews/<action>-<subject-slug>.md`
- `realignments/<change-slug>.md`
- `guidance/<pr-id>.md`
- `pull-requests/<nn>-<domain>-<purpose-slug>-packet.md`
- `pull-requests/<nn>-<domain>-<purpose-slug>-build.md`, one per build attempt; a
  second attempt is `-build-2.md` and the first is collapsed to one line in its
  Prior attempts list
- `pull-requests/<nn>-<domain>-<purpose-slug>-review.md`
- `reports/<feature-slug>-final.md`
- `superseded/<readable-path-without-ext>/v<n>.md`

Packets exist only under `pull-requests/` and are written only by `sequence-prs` or
`realign-run`. Planning writes no packets.

The published pack is `docs/features/<feature-slug>/` unless discovery found another
feature-doc convention: `README.md`, `technical-spec.md`, `architecture-overview.md`,
`glossary.md`, `sequence.md`, and `prs/<nn>-<domain>-<purpose-slug>.md`. See
[published-docs.md](published-docs.md). The published technical spec is the only
requirements document and the published overview is the only overview; neither has a
run-folder copy.

## Consistency check

Before every approval request, before dispatching a builder, and before the final report,
the orchestrator verifies and records the result in `run.md`:

1. every path in the index, `run.md`, and the published README exists;
2. every version named in a human review record has an index row;
3. every status word is in the glossary vocabulary;
4. no two live files under `pull-requests/` share a sequence number;
5. every build packet references a guidance manifest that exists and a glossary row set;
6. every `v2+` artifact has a `Changed since` section;
7. no alias row has equal old and new names;
8. the Where things stand table matches branch, PR, and index state.

A failed check blocks the checkpoint until repaired. The check is a short table of pass
and fail lines, not prose.

## Evidence

Evidence references must be reproducible and concise:

- repository-relative file path plus line range or symbol
- command and summarized result, with full output saved only when needed
- test/check name and pass/fail result
- authoritative external reference and access date
- artifact ID for prior accepted analysis

Distinguish `observed`, `inferred`, `assumed`, and `unknown`. An inference names its
supporting observations. An assumption names its validation owner and checkpoint, and
Ponytail must give a verdict on every assumption before build.

## Phase completion

A phase is complete only when its required artifact:

1. exists at the scheduled path,
2. is indexed,
3. records inputs and evidence,
4. states unresolved unknowns or blockers,
5. passes the consistency check, and
6. has index status `accepted` or an explicit authorized exception.

Workers report `complete`. Only the orchestrator marks an artifact `accepted`, and only
a human records `approved` at a checkpoint.
