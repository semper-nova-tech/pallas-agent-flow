---
name: quick-change
description: Runs a one-PR change with Sonnet building, Haiku agents searching and auditing, and Opus signing off at three decision points. Use for fixes, small enhancements, dependency bumps, CI triage, audits, and doc fixes. Hands off to Pallas Agent Flow when the work needs more than one PR or changes a shared contract.
---

# Quick change

The main session builds. Haiku agents search and run checks so their output stays out
of the main context. Opus reviews only at three moments. Nothing is saved outside the
branch: no run folder, glossary, PRD, or packets.

## Helpers

| Job | Helper |
| --- | --- |
| Map an unfamiliar area | `map-repo` |
| Find every use of a symbol, string, or key | `find-call-sites` |
| Run checks and review the diff | `audit-diff` |
| Opus decision | the session's advisor tool if it has one, otherwise `sign-off` |

Answer a question with one Grep, Glob, Read, or git command when that is enough. Use a
helper when the answer needs several searches or a long command output.

## Steps

1. **Check fit.** State the scope in one line. Stop and hand off when the work:
   - needs more than one PR
   - changes an export, API, event, or schema that another team or project consumes
   - needs a new domain term, migration, or feature flag
   - has no clear before and after
2. **Find the code** with direct tools, `map-repo`, or `find-call-sites`.
3. **Plan.** If the approach is not obvious, ask Opus with moment `plan` before
   editing. Act on `change`; hand off on `full-flow`.
4. **Change the code** in this session, following the repository's agent instructions
   and standards docs.
5. **Audit.** Run `audit-diff` with the scope and base branch. Fix what it reports and
   run it again.
6. **Repeated failure.** When the same check fails with the same error twice, ask Opus
   with moment `repeated-failure` instead of trying a third fix.
7. **Done.** Ask Opus with moment `done`, giving it the scope, diff, and the last
   `audit-diff` result. Then run the repository's comment-cleanup and PR skills if it
   has them.

## Hand-off

When a fit check or an Opus `full-flow` verdict stops the work, tell the user why and
give a short note for `/pallas-agent-flow:product-spec` or
`/pallas-agent-flow:orchestrate-feature`: the request, the files and call sites found,
and the reason it does not fit one PR. Leave the branch as it is.

## Report

End with:

```markdown
Before: <behavior before>
After: <behavior after>
See it: <how to observe the change>
Files: <changed files>
Checks: <commands and results from the last audit-diff>
```
