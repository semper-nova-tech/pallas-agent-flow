# Human-Readable Output Policy

Write for people first and retain IDs for machine traceability.

## Named records

At creation, every frontier item, requirement, design, contract, model, state, behavior,
finding, decision, architecture draft, ADR, approval or review, realignment, PR, packet,
build, and report receives:

- a concise human-readable display name
- a one-sentence plain-language meaning or purpose
- a stable internal ID

Lead with the name. On first mention, write `Display name (internal ID)` and add the
meaning when the name is not self-explanatory. Later use the name alone; include the ID
only for disambiguation or exact traceability. Never make a user decode a raw ID.

## Narration and approvals

Use plain-language statuses and call a human pause an `approval checkpoint`, not a bare
`gate`. Explain invalidation as what changed, what can no longer be trusted, and what must
be reviewed again.

Replace dense bulk narration with numbered, named decisions. State each consequence, then
add a separate `Open questions` section. Approval requests use numbered, named actions.
Isolate each destructive action, name the exact file, worktree, or branch and its
consequence, and require separate approval. Never include it in bulk approval.

## Readable paths

Use stable lowercase slugs derived from feature, design, or action purpose:

Published, committed review files:

- `docs/features/<feature-slug>/README.md`
- `docs/features/<feature-slug>/technical-spec.md`
- `docs/features/<feature-slug>/architecture-overview.md`
- `docs/features/<feature-slug>/sequence.md`
- `docs/features/<feature-slug>/prs/<nn>-<domain>-<purpose-slug>.md`

Run-folder evidence, gitignored with `.lore-flow/`:

- `prd-reviews/<feature-slug>.md`
- `architecture/<feature-slug>-frontend.md`, `-backend.md`, or `-infrastructure.md`
- `decisions/<decision-slug>.md`
- `human-reviews/<action>-<subject-slug>.md`
- `realignments/<change-slug>.md`
- `pull-requests/<sequence>-<domain>-<purpose-slug>-packet.md`
- matching `-build.md` and `-review.md` paths for PR results
- `reports/<feature-slug>-final.md`

Internal IDs and versions belong in metadata and the artifact index, not filenames.
Legacy canonical names may remain as index aliases or compatibility references; do not
force duplicate files.

## Index and renames

Artifact index rows lead with the readable name and path; internal ID, version, and
status follow as columns. See [run-schema.md](run-schema.md).

Renames preserve stable IDs and name aliases. Change a readable filename only through an
explicit realignment plan. Record the old path and new path so prior links remain
traceable; do not silently move or duplicate artifacts.
