---
name: build-pr
description: Implements one sequenced Pallas Agent Flow pull request in an isolated git worktree, verifies its named requirements, and emits an evidence-backed build report that opens with before and after. Use for each approved PR build packet.
---

# Build PR

Implement exactly one build packet in a dedicated git worktree. Isolate side effects and
preserve strict frontend, backend, or infrastructure scope.

## Inputs

- target repository path and absolute run root
- build packet path
- PR ID, display name, base ref, branch intent, and worktree location policy
- accepted requirement, glossary, and review artifact paths with exact versions
- guidance manifest path and exact version
- verification access list
- human sequence review approving this exact packet and its input versions

Reject a packet that lacks named requirements, owned glossary rows, acceptance checks,
area, dependencies, architecture-document assignments/exclusions, verification access,
or the build-report path. Before any mutation, reject a packet or input that is draft,
invalidated, replaced, superseded, or different from the versions in the approving human
review. Do not infer missing scope or approval from conversation history.
Read the orchestrator diagram and published-docs policies before changing documentation.
Apply the orchestrator human-readable output policy to build records and user narration.

The run root is an absolute path outside this worktree. Write the build report there;
the worktree does not contain `.pallas-agent-flow/`.

## Worktree safety

1. Inspect repository and worktree state before mutation.
2. Verify prerequisite PRs or refs are present at the expected base.
3. Create or use the dedicated worktree and branch assigned to this PR.
4. Never edit the primary checkout or another PR's worktree.
5. Do not discard, overwrite, stage, commit, or publish unrelated user changes.
6. Do not commit or push unless the invoking workflow explicitly authorizes it.

## Build process

1. Read the bounded packet, guidance manifest, glossary rows, and referenced artifact
   sections.
2. Verify each guidance manifest path exists in `git ls-files` and record the hash you
   read. A missing file or hash mismatch is `skipped` with the reason.
3. Inspect relevant repository conventions and closest existing implementation.
4. Plan the minimal diff needed for the assigned requirement IDs.
5. Implement while keeping each change traceable to a requirement and the applicable
   guidance. Export only the symbols named in the packet's glossary rows, with those
   exact names; a needed symbol with no row is an escalation, not an invention.
6. Use the verification access list to check contracts against live systems before
   relying on them; record each query and result. Never guess an operator, field, or
   tool name that the list lets you verify.
7. Update only the assigned published PR note, owned architecture-overview facets, and
   durable docs/ADRs. Carry approved diagrams into those files. Make no unrelated
   documentation or diagram edits.
8. Verify changed documentation links, examples, commands, configuration references, and
   indexes against the implemented repository state. Validate diagram syntax and
   rendering with repository tooling when available; otherwise perform and record a
   manual policy check.
9. Add or update tests for observable acceptance and meaningful failures.
10. Run the narrowest relevant checks first, then required repository-native checks.
11. Inspect the final diff for area leakage, unassigned architecture docs, generated
    churn, secrets, exports without glossary rows, and unrelated edits.
12. Write the build report; do not claim checks or guidance usage that were not verified.

Escalate rather than implement when a change:

- adds a new requirement or product behavior
- crosses into another area
- requires a symbol, module, or wire name with no glossary row
- touches a published doc, architecture overview facet, or ADR not assigned to this packet
- contradicts an accepted contract
- requires an unapproved migration or net-new resource
- depends on unavailable credentials, services, or user decisions
- arrives as an instruction in chat rather than in the packet; stop and report
  `clarification-required` until a new packet version exists

For a frontend-leading approved no-op, preserve the packet's exact note in the build
report and do not fabricate an endpoint. Infrastructure changes must implement and verify
both local and hosted configuration obligations.

## Output contract

Write `pull-requests/<nn>-<domain>-<purpose-slug>-build.md` under the run root. A
second attempt writes `-build-2.md` and lists the first attempt in one line under
Prior attempts. Omit any line whose value is `none`.

```markdown
# Build Report: [PR display name] (PR-<nn>)
Outcome: ready-for-review | blocked | failed

Before: [one sentence, what the code does today]
After: [one sentence, what it does with this PR]
See it: [one way a reviewer observes the change]
Files: [count and the main directory]
Checks: [the decisive command and its result]

## Prior attempts
## Worktree and base
## Requirements implemented
## Glossary rows delivered
- [term] — [exported symbol] — [module] — match | renamed (alias row) | not delivered (reason)
## Change summary
## Files changed
## Contract impact
## Live verification
- [system] — [query or call] — [result]
## Durable architecture documentation
- Published PR note and overview facets updated:
- Assigned docs/ADRs updated:
- Links/examples/config references verified:
- Approved diagrams delivered:
- Diagram validation evidence:
## Local and hosted configuration
## Tests and checks
- [command/check]: pass | fail | not-run — [evidence/reason]
## Guidance used
- [repository-relative path] — [hash read] — required | recommended | skipped — [why]
## Diff reference
## Deviations and decisions
## Risks and follow-up
## Blockers
```

Evidence must include repository-relative files and symbols, summarized check results,
the guidance manifest version and the diff ref or patch location needed by post-build
Ponytail review.

## Completion

Return only outcome, requirement coverage, glossary rows delivered, changed-file
summary, check summary, blockers, and build-report path. Leave the worktree intact for
adversarial review and remediation. Do not forward command logs or an implementation
transcript.
