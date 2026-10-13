# Human-Readable Output Policy

Write for people first and retain IDs for machine traceability. Vocabulary, ID prefixes,
and status words come from the plugin [glossary](../../../docs/glossary.md).

## Named records

At creation, every frontier item, requirement, term, finding, decision, architecture
draft, ADR, review, realignment, PR, packet, build, and report receives:

- a concise human-readable display name
- a one-sentence plain-language meaning or purpose
- a stable internal ID using the reserved prefix for its record type

Lead with the name. On first mention, write `Display name (internal ID)` and add the
meaning when the name is not self-explanatory. Later use the name alone; include the ID
only for disambiguation or exact traceability. Never make a user decode a raw ID, and
never introduce a second ID scheme inside a run.

## Naming rules

- One canonical name per concept, recorded as a feature glossary row. Prose, headings,
  diagrams, packets, branch names, and PR titles use that name verbatim.
- Behaviors and functions are verb-first sentences that read without context:
  `resolveCompSearchAnchor`, `Resolve the page's place before delegating`. Models and
  terms are nouns: `CompSearchAnchor`, `Lease comp`.
- A display name says what the thing does, not which phase produced it. "Posts
  compressor injection" names a mechanism; "Look up Infabode posts for the market agent"
  names the behavior.
- No abbreviations or single-letter symbols that the glossary does not define.
- A PR has exactly one display name, used identically in the sequence, the packet, the
  PR note, the build report, the index, and the Git PR title.
- Changing a name is an alias row first, then a label refresh. Changing a meaning is a
  scope change.

## Current state, future state, and what changed

Every artifact that describes a change states, in this order, what is true today, what
will be true after, and what changed since the previous version of the artifact:

- Requirements carry `Today:` and `After:` lines.
- The architecture overview opens with `## Today → After`.
- Published README and technical spec carry a `Status:` line.
- Build reports and PR notes open with a five-line block:

```md
Before: the market agent validates places with validate_location against OpenSearch.
After: both agents call resolve_place_representations through the data platform MCP.
See it: ask "comps near 123 Main St" in the sales chat; the tool card names the resolved place.
Files: 7 changed in libs/crexi-ai/backend/feature/market-context-agent
Checks: pnpm nx test market-context-agent — pass
```

- Any `v2` or later artifact opens with:

```md
## Changed since v1
- Added: Lease listing term and search_lease_listings wire name (Terms, Requirements)
- Changed: PR-02 now binds server tools per run (Sequence)
- Removed: anchor-plus-radius lease comps, retired by D-020 (Requirements, Coverage)
```

Omit lines whose value is `none` ("Approved diagrams delivered: none were assigned")
rather than printing boilerplate.

## Narration and approvals

Use plain-language statuses and call a human pause an `approval checkpoint`. Explain
invalidation as what changed, what can no longer be trusted, and what must be reviewed
again.

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
- `docs/features/<feature-slug>/glossary.md`
- `docs/features/<feature-slug>/sequence.md`
- `docs/features/<feature-slug>/prs/<nn>-<domain>-<purpose-slug>.md`

Run-folder evidence, gitignored with `.pallas-agent-flow/`:

- `prd-reviews/<feature-slug>.md`
- `discovery/<feature-slug>-<area>.md`
- `architecture/<feature-slug>-<domain>.md` for domain drafts only
- `decisions/<decision-slug>.md`
- `human-reviews/<action>-<subject-slug>.md`
- `realignments/<change-slug>.md`
- `guidance/<pr-id>.md`
- `pull-requests/<nn>-<domain>-<purpose-slug>-packet.md`
- matching `-build.md` and `-review.md` paths for PR results
- `reports/<feature-slug>-final.md`
- `superseded/<readable-path-without-ext>/v<n>.md`

Internal IDs and versions belong in the artifact index, not filenames or body headers.

## Index and renames

Artifact index rows lead with the readable name and path; internal ID, version, and
status follow as columns. See [run-schema.md](run-schema.md).

Renames preserve stable IDs and add alias rows. Change a readable filename only through
an explicit realignment plan. Record the old path and new path so prior links remain
traceable; do not silently move or duplicate artifacts.
