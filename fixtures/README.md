# Lore Flow fixtures

These compact scenarios exercise dependency planning and approval checkpoints and reviews. Each
fixture contains a PRD-like input followed by the significant portion of the
expected plan artifact. IDs are illustrative and assertions should compare
relationships and states rather than array order unless `sequence` is present.

| Fixture | Rule exercised |
| --- | --- |
| `backend-first-feature.md` | Provider precedes frontend consumer |
| `frontend-first-no-op.md` | Explicit no-op permits frontend-first work |
| `late-infrastructure.md` | Non-blocking infrastructure can land late |
| `blocking-net-new-infrastructure.md` | New blocking infrastructure lands first |
| `contract-migration.md` | Expand, migrate, then contract |
| `failed-ponytail-review.md` | Failed required review blocks dependents |
| `human-realignment.md` | Rename traceability and bounded design invalidation |
| `architecture-documentation.md` | Run drafts and area-owned durable docs/ADRs |
| `diagram-policy.md` | YAGNI diagram triggers, homes, PR DAG, and no-diagram case |
| `human-readable-naming.md` | Readable names, paths, narration, and isolated approval |
| `published-review-surface.md` | Committed spec, overview, sequence, and PR notes outside `.lore-flow/` |
| `feature-glossary.md` | Glossary rows as the naming contract, meaning change as scope, export reconciliation |
