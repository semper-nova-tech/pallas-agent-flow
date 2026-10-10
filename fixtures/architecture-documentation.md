# Architecture documentation ownership

## Input

Add a versioned bulk-export API backed by a new object-storage bucket. Document the API
contract, deployment/storage topology, and the decision to use asynchronous export jobs.
The repository has no architecture or ADR convention.

## Expected plan artifact

```json
{
  "published": [
    "docs/features/bulk-export/README.md",
    "docs/features/bulk-export/technical-spec.md",
    "docs/features/bulk-export/architecture-overview.md"
  ],
  "drafts": [
    "architecture/bulk-export-backend.md",
    "architecture/bulk-export-infrastructure.md",
    "decisions/asynchronous-export-jobs.md"
  ],
  "units": [
    {
      "displayName": "Provision export storage",
      "purpose": "Provide local and hosted storage for export files.",
      "internalId": "PR-01",
      "area": "infrastructure",
      "durableDocs": ["docs/architecture/export-storage.md"]
    },
    {
      "displayName": "Build bulk export API",
      "purpose": "Create and expose asynchronous bulk export jobs.",
      "internalId": "PR-02",
      "area": "backend",
      "dependsOn": ["PR-01"],
      "durableDocs": [
        "docs/architecture/bulk-export-api.md",
        "docs/adr/async-export-jobs.md"
      ]
    }
  ]
}
```

The infrastructure document is owned by the infrastructure PR. The API contract and ADR
are owned once by the contract-producing backend PR; no mixed-domain documentation PR is
created.
