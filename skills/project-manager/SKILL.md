---
name: project-manager
description: Reports where product work stands and the next step for each item, from the committed portfolio plus local worktrees, Herdr worktrees, and remote branches. Offers to add untracked or discovery work to the roadmap. Use to spin up on any machine, harvest in-progress status, record a finished PRD, or rewrite the roadmap after a PRD completes.
---

# Project manager

Keep one portfolio for the target repository so any machine can say what is an
idea, what is in progress, and what to do next. Do not implement the product.
Do not start `product-spec` or `orchestrate-feature` unless the human asks.

The portfolio is committed product context. `.pallas-agent-flow/` is this
machine's evidence only. A PRD another machine cannot see is not in the
portfolio yet.

## Files

Use the same product root as `product-spec`, usually `product/`.

| File | Role | Write rule |
| --- | --- | --- |
| `roadmap.md` | Strategic direction: where the product is going | Leave it alone during a status harvest. Several PRDs may sit in Now together. Rewrite the whole file only when one PRD is completed, or when the human changes direction. The rewrite drops the finished slug and keeps every slug that is still in progress or still an idea. |
| `in-progress.md` | Harvested status | Replace the whole file on every run. |
| `completed-prds.md` | Ledger of finished PRDs | Append one row. Do not rewrite earlier rows. |

Create a missing file from `templates/product/ROADMAP.md`,
`templates/product/IN_PROGRESS.md`, or `templates/product/COMPLETED_PRDS.md`.
Do not invent Direction, Now, Next, or Later. If the roadmap has no items, say
so and ask.

Now, Next, and Later may each hold several lines. Each line names one feature
slug in backticks. An idea is a roadmap line with no `product/prds/<slug>.md`
on the default branch and none on a harvested branch or worktree.

## Portfolio modes

Use these modes in `in-progress.md` only. They are not run statuses.

| Mode | Meaning |
| --- | --- |
| `idea` | Named on the roadmap. No PRD file in the harvest. |
| `drafting` | A PRD file exists, and this machine has no approval record for it. |
| `ready` | An approval record on this machine says `approved`, and the PRD is not on the default branch. |
| `discovery` | A PRD exists, and the feature pack or local run is still in planning. No `sequence.md` yet, or the published `Status:` is `planned`, or the local run phase is `intake`, `technical-specs`, or `spec-review`. |
| `building` | `sequence.md`, a PR note, an implementation branch, or an open implementation pull request exists, and the work is not finished. |
| `blocked` | The harvest names a blocker and the smallest action that clears it. |

A PRD on the default branch is in the portfolio. A PRD that exists only on
another branch is not, until someone lands it there.

## Harvest

Do this every run, before rewriting `in-progress.md`. Read-only. Do not check
out other branches, create worktrees, push, or open a pull request.

1. Resolve the default branch with
   `git symbolic-ref --short refs/remotes/origin/HEAD`. If that ref is missing,
   use `main`, then `master`.
2. Run `git fetch --prune`. If the fetch fails, continue with the refs already
   present and say the remote was not refreshed.
3. List committed portfolio paths without checking them out:
   `git ls-tree -r --name-only <origin/default> -- product docs/features`.
   Read each `product/prds/*.md` and each `docs/features/*/README.md` `Status:`
   line with `git show <origin/default>:<path>`.
4. List local worktrees with `git worktree list --porcelain`. In each worktree,
   note branch, dirty state, and any `product/prds/*.md` or
   `docs/features/<slug>/` files. A pack with no `sequence.md`, a `Status:` of
   `planned`, or a local `run.md` whose `current-phase` is `intake`,
   `technical-specs`, or `spec-review` is `discovery`.
5. For each remote branch other than the default, run
   `git diff --name-only <origin/default>...<branch> -- product/prds docs/features`.
   Record a branch only when that diff is non-empty. Read the changed PRD and
   the pack `Status:` line with `git show`. A pack that has no `sequence.md` is
   `discovery`. Do not inspect branches with no product or feature-doc diff.
6. When `herdr` is on `PATH`, run `herdr worktree list`. Match each path or
   branch to the git harvest. If the command fails, record Herdr as unavailable
   and continue. Do not create or remove a Herdr worktree.
7. When `gh` is authenticated, run
   `gh pr list --state open --json number,title,headRefName,baseRefName,url`
   and attach a PR to the branch it names. If `gh` fails, skip it.
8. On this machine only, read
   `.pallas-agent-flow/product-specs/*/approval-record.md` when those files
   exist. An `approved` record makes that slug `ready` if its PRD is not on
   the default branch. Absence of the record does not mean the PRD was
   rejected. Another machine will not have this directory.

Published `Status:` of `shipped`, `pivoted`, or `abandoned` on the default
branch is evidence for the ledger. Do not append the ledger or rewrite the
roadmap until the human confirms that PRD is finished.

## Not on the roadmap

After the harvest, compare every slug you found with the slugs named on
`roadmap.md`. A slug that is missing is untracked. That includes a worktree or
branch that only looks like discovery.

Report each untracked slug with the stage the files support and where you
found it. Offer to add one line under Now, because the work already exists.
Do not edit `roadmap.md` until the human accepts. An accepted line is inserted.
It is not a reason to rewrite the rest of the roadmap.

## Next step for each stage

Read the PRD and the feature-pack files far enough to pick the stage. Then
name the next step for that stage. Do not collapse several items into one
action.

| Stage | Next step |
| --- | --- |
| `idea` | No files yet. Next is `product-spec` when the human wants to start it. |
| `drafting` | Continue the interview, or ask for approval of the current draft. |
| `ready` | Open a pull request onto the default branch with `product/prds/<slug>.md` and the glossary or persona rows the interview changed. |
| `discovery` | Continue `orchestrate-feature` through technical specs and the requirements checkpoint. Do not start builds. |
| `building` | Name the open pull request, or the next PR note that has no open pull request. One next step per PR. |
| `blocked` | The smallest action that clears the blocker. |

## Land a ready PRD

When a slug is `ready`, the next action is a pull request onto the default
branch containing `product/prds/<slug>.md` and the glossary or persona rows
that interview changed. Say that in `in-progress.md` and in the spin-up.
Opening the pull request waits for the human. Until that pull request is on
the default branch, `project-manager` on another machine can see the branch
and cannot see the approval.

## Record a completion

When the human says a PRD is finished, or confirms a published `Status:` of
`shipped`, `pivoted`, or `abandoned`:

1. Append one row to `completed-prds.md`: date, slug, that outcome, a one-line
   summary, the PRD path, and the evidence (default-branch commit, pack path,
   or pull request). `shipped`, `pivoted`, and `abandoned` are the only
   outcomes.
2. Rewrite `roadmap.md` from the template headings. Drop only the finished
   slug. Keep Direction, and keep every other Now, Next, Later, and Not now
   line. Do not promote another item just because one PRD finished. Do not add
   a "recently finished" section. The ledger holds that.
3. Show the human the new roadmap and the new ledger row.

## Spin-up

Rewrite `in-progress.md` from the template. Put every found slug in the section
for its stage, with where it was found and its next step. Put untracked slugs
in Not on the roadmap as well, including the offer to add them.

Then explain the same assessment to the human. Group by stage. For each item
say the slug, where it was found, what the files show, and the next step from
the table above. End the untracked group with the offer to add those lines to
Now. Do not stop at a single next action when more than one item was found.

```markdown
Default branch: <name @ sha> (remote refreshed | remote stale)

## <Stage>
- `<slug>` — <where>. Files: <what you read>. Next: <the step for this stage>.

## Not on the roadmap
- `<slug>` — <stage> on <where>. Offer: add it under Now.
```

Commit the refreshed `in-progress.md`, an accepted roadmap line, or a ledger
or roadmap rewrite only when the human asks. Do not push.
