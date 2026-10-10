# Human-readable naming fixture

## Input failure pattern

```text
F-002 invalidates ART-007 v3. REV-002 rejected D-F1-R2.
Approve RA-001 and PR-03, including replacement of wt-pr-03.
```

This fails because people must decode IDs, invalidation has no explanation, and a
destructive worktree replacement rides in a bulk approval.

## Expected narration

1. **Hosted order events (F-002)** — Send accepted orders through the hosted event
   runtime.
   Consequence: the **Order service topology draft (ART-007)** version 3 assumes an
   in-process queue, so it can no longer support implementation and needs review again.
2. **Reject speculative retry service (REV-002)** — The review rejects
   **Add retry service (D-F1-R2)** because no requirement needs a separate service.
   Consequence: remove that design from the proposed architecture.
3. **Realign hosted order delivery (RA-001)** — Update only affected requirements,
   diagrams, and PR dependencies while preserving accepted frontend work.
   Consequence: return to the Requirements approval checkpoint.

## Open questions

- Should hosted delivery retry in the existing worker or fail for operator recovery?

## Readable filenames

- `prd-reviews/hosted-order-events.md`
- `architecture/hosted-order-events-infrastructure.md`
- `decisions/order-event-retry.md`
- `human-reviews/approve-hosted-order-requirements.md`
- `realignments/hosted-order-delivery.md`
- `pull-requests/03-backend-publish-order-events-packet.md`
- `pull-requests/03-backend-publish-order-events-build.md`
- `pull-requests/03-backend-publish-order-events-review.md`
- `reports/hosted-order-events-final.md`

The artifact index records old canonical paths as aliases without creating duplicate
files. IDs and versions remain metadata.

## Separate destructive approval

Approval 1: **Approve hosted order sequence** — Approves the named PR order and packets.

Approval 2, required separately: **Replace backend order worktree** — Delete and recreate
worktree `/worktrees/03-backend-publish-order-events` on branch
`feature/publish-order-events`. This discards its uncommitted changes. Approve or reject
this action independently; it cannot be included in Approval 1.
