# Feature glossary fixture

## Input failure pattern

Across one run the same concept appears as `find_lease_comps` (planned tool),
`search_lease_listings` (shipped tool), `DataPlatformGraphQLSender` (packet),
`DataPlatformGraphQLConnection` (code), and "lease comps" / "lease listings" in prose.
Nothing records that *comp* became *listing*, so a dropped radius search passes as a rename.

## Expected glossary rows

| Term | Meaning | Kind | Owner | Model | Functions | Module | Wire name | Status | Alias of |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Lease comp | A completed lease transaction used for rent comparison | model | backend | `LeaseComp` | `findLeaseCompsNearAnchor` | `data-platform-client` | tool `find_lease_comps` | new | |
| Comp search anchor | The property or point a comp search is centered on | model | backend | `CompSearchAnchor` | `resolveCompSearchAnchor` | `data-platform-client` | | new | |
| Data platform connection | The transport a tool uses to reach the data platform | contract | backend | `DataPlatformConnection` | `createMcpDataPlatformConnection` | `data-platform-client` | env `CREXI_DATA_PLATFORM_MCP_URL` | renamed | `DataPlatformGraphQLSender` |

## Expected realignment classification

A reviewer replaces `find_lease_comps` with the server's `search_lease_listings`.

- The wire name changed **and** the meaning changed from lease comp to lease listing.
- Classification: `scope`, not `rename-only`. A new row `Lease listing` is added; the
  `Lease comp` row becomes `retired` with the decision that retired it.
- Invalidation: the requirement that promised anchor-plus-radius lease comps can no
  longer be trusted and returns to the requirements approval checkpoint.

## Expected final-report reconciliation

| Row | Module export | Result |
| --- | --- | --- |
| `createMcpDataPlatformConnection` | present in `src/index.ts` | match |
| `findLeaseCompsNearAnchor` | absent | planned, not shipped (retired by D-020) |
| `getDataPlatformMcpTools` | present, no row | export without a term; add a row or remove the export |
