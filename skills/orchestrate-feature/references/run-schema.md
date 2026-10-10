# Lore Flow Run Schema

Use human-readable Markdown. JSON-compatible values shown below define required fields,
not a requirement to use JSON.
Apply [human-readable-output.md](human-readable-output.md) to all records and paths.

## Run manifest

Create `.lore-flow/runs/<run-id>/run.md` with:

- `run-id`: unique, filesystem-safe identifier
- `status`: `active`, `awaiting-human-review`, `realigning`, `blocked`, `completed`, or
  `failed`
- `target-repository`: canonical path
- `prd-source`: path plus the approved commit (`path@commit`), or authoritative
  reference. Read an older approved version with `git show <commit>:<path>`.
- `preset`: selected key from `config/presets.json`, with its resolved harness, gates,
  and role/model mappings
- `harness`: resolved adapter or harness name
- `started-at` and `updated-at`: ISO-8601 timestamps
- `current-phase`: workflow phase name
- `constraints`: user and repository constraints
- `decisions`: names and outcomes, with internal IDs as metadata
- `pending-approval`: checkpoint name, reviewer, policy, and exact artifact versions
- `blockers`: names and resolutions, with internal IDs and owners as metadata

Do not store secrets, credentials, or full transcripts.

## Artifact index

Create `artifact-index.md` as one Markdown table, one row per artifact version:

| Name | Path | ID | Version | Predecessor | Status | Producer | Inputs |
| --- | --- | --- | --- | --- | --- | --- | --- |

- **Path** is relative to the run root or repository-relative for published files.
- **Version** is `v<n>` for run artifacts and the Git blob hash
  (`git hash-object <path>`) for published files; never copy a published file into the
  run folder to version it.
- **Status** is `complete`, `accepted`, `approved`, `superseded`, or `blocked`.
- Record aliases in `aliases.md`; diagram purpose, type, and source requirements live
  in the document that embeds the diagram.

Add a row in the same step that writes the artifact. Preserve superseded artifacts or clearly record
their replacement; do not silently overwrite material decisions.

An accepted version is immutable. A candidate may coexist with it during review. Record
`superseded-by`, supersession reason, and approving review before marking the prior
version `superseded`.

## Human review records

Create one readable record per review under `human-reviews/`. Record:

- display name, plain-language purpose, stable review ID, and checkpoint ID
- reviewer identity
- decision: `approved`, `changes-requested`, or `rejected`
- ISO-8601 timestamp and comments
- reviewed artifact IDs and exact versions
- policy or preset that required the approval checkpoint
- resulting status, decision IDs, and realignment ID when applicable

The mandatory approval checkpoints are Technical requirements and PR sequence. Per-PR
approval before each build is on by default and uses the same record shape; disable it
only with `each-pr: false`. Approval applies only to listed versions; explain plainly
why a material new version needs review again.

## Realignment and traceability

Maintain:

- `aliases.md`: stable ID, old name, new name, direction, reason, review ID, and timestamp
- `invalidations.md`: changed source version, classification, dependency path, impact,
  affected version, proposed action, and disposition
- `realignments/<change-slug>.md`: changed artifacts, transitive impact, minimal rerun,
  preserved artifacts, implementation proposals, approvals, and next checkpoint

Change classification is `rename-only`, `requirement`,
`contract-model-state-behavior-design`, `sequencing`, or `scope`. Impact is `none`,
`label-refresh`, `revalidate`, or `regenerate`. Keep unaffected accepted artifacts
accepted and retain all prior review and decision history.

## Readable artifact layout

Use lowercase purpose slugs:

- `prd-reviews/<feature-slug>.md`
- `discovery/<feature-slug>-<area>.md`
- `architecture/<feature-slug>-<domain>.md` when a domain draft is needed
- `decisions/<decision-slug>.md`
- `human-reviews/<action>-<subject-slug>.md`
- `realignments/<change-slug>.md`
- `pull-requests/<sequence>-<domain>-<purpose-slug>-packet.md`
- matching `-build.md` and `-review.md` PR artifacts
- `reports/<feature-slug>-final.md`

Keep shared indexes, aliases, and invalidation records at stable descriptive paths.
Legacy canonical filenames may be index aliases; do not create duplicate files merely
for compatibility.

The committed review surface is the published pack in
`docs/features/<feature-slug>/` unless discovery found another feature-doc convention:
`README.md`, `technical-spec.md`, `architecture-overview.md`, `sequence.md`, and
`prs/<nn>-<domain>-<purpose-slug>.md`. See [published-docs.md](published-docs.md).

The published technical spec is the only requirements document and the published
architecture overview is the only overview; neither has a run-folder copy. Domain
architecture drafts under the run root are evidence. Durable domain docs still
follow the repository convention, or `docs/architecture/` and `docs/adr/` when none
exists. Diagrams live in the published architecture overview and PR notes by default.

Target repositories should gitignore `.lore-flow/`.

## Evidence

Evidence references must be reproducible and concise:

- repository-relative file path plus line range or symbol
- command and summarized result, with full output saved only when needed
- test/check name and pass/fail result
- authoritative external reference and access date
- artifact ID for prior accepted analysis

Distinguish `observed`, `inferred`, `assumed`, and `unknown`. An inference names its
supporting observations. An assumption names its validation owner and checkpoint.

## Phase completion

A phase is complete only when its required artifact:

1. exists under the run root,
2. is indexed,
3. records inputs and evidence,
4. states unresolved unknowns or blockers, and
5. has index status `accepted` or an explicit authorized exception.

Workers report `complete`. Only the orchestrator marks an artifact `accepted`, and only
a human records `approved` at a checkpoint.
