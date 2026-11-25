---
name: diff-code-review
description: Reviews one pull request or branch from the terminal without touching the user's checkout. Pulls it into a worktree, diagrams the changed code by package with Skema, reviews it for architectural simplicity and naming, and compacts the findings into a rename and simplification table plus line-by-line comments. Posts to the PR only after the user picks root-level or line-by-line. Uses Hunk to walk the diff and hold inline notes when it is installed. Never edits the code under review. Use for "review PR 123", "review this branch", or a pull request URL.
---

# Diff code review

This skill reviews one change for shape and names, all in the terminal: no artifact, web
page, or doc. It reads the code and never edits it. Diagrams, notes, and comment payloads
go to the session's scratch folder (or `mktemp -d`), never into the worktree. Nothing
reaches the pull request until the user says how to post it.

It does not hunt for correctness bugs. When the user seems to expect that, say so and
point them to the harness's bug review.

## Tools

Check all three once at the start. Name everything missing in one line, with what the
review loses without it. Never install a tool, skill, or Herdr plugin without asking,
including an install the `skema-diagram` skill offers.

| Tool | Present when | With it | Without it |
| --- | --- | --- | --- |
| Skema | `skema-diagram` is in the session's skill list and `skema --version` is 0.3.3 or newer | Manifests rendered to SVG, following that skill | plain-text diagrams in fenced blocks |
| Hunk | `cli-hunk` is in the skill list, `command -v hunk` succeeds, and so does `hunk session --help` | walk the diff and place the line comments in the user's live session, following that skill | walk with `git diff`; comments stay in the report |
| `gh` | `gh auth status` succeeds | read the PR and post to it | branch review only; nothing to post |

## Helpers

| Job | Helper |
| --- | --- |
| Map packages, entry points, and imports around the changed files | `map-repo` |
| Find every caller of an export a finding renames | `find-call-sites` |
| Review the diff through one lens, `simplicity` or `naming` | `review-diff-lens` |

## Steps

1. **Pull the change.** Take a PR number, PR URL, or branch name. First record the user's
   branch and `git status --short`. Never switch, stash, reset, or pull in their checkout.
   - PR: `gh pr view <pr> --json number,url,headRefOid,baseRefName`, then
     `git fetch origin pull/<number>/head`. A URL for another repository needs that
     repository's clone; ask for it.
   - Branch: `git fetch origin <branch>`. The base is the default branch unless named.
   - `git worktree add --detach <repo-parent>/<repo>-review-<number-or-branch> <head-sha>`.
     Reuse that worktree when it already sits at the same commit.
   - The range is `origin/<base>...HEAD`. With Hunk, read its order from
     `hunk session review --json` rather than the whole patch. Past about 1,500 changed
     lines, say so and ask whether to review all of it or a named part.
   - Look in the worktree for run machinery: a run or start skill, `dev`, `start`, or
     `serve` scripts, a compose file, `run`, `dev`, or `up` Make targets, a Procfile. If
     there is some, offer once in one line, naming the exact commands, any dependency
     install included. Run it only on a yes, from the worktree, in its own pane or a
     background shell, and stop it before the report. With nothing to run, say nothing.
2. **Diagram the change.** Ask `map-repo` for the package or library boundaries around the
   changed files (workspace and package manifests, module files, top-level source
   folders) and the imports between them. Draw two diagrams, each under about 15 Nodes,
   with unchanged neighbors collapsed to one Node per package:
   - **Code flow:** entry point to effect through the functions the change adds, edits,
     or calls. One Separator per package boundary. Say `new` or `changed` in the Node
     description.
   - **Inheritance and dependency:** changed classes, interfaces, and modules, with
     Edges for extends, implements, and imports across packages. Mark an Edge that
     points the wrong way across a boundary.

   With Skema, write `flow.json` and `inheritance.json` to the scratch folder and follow
   `skema-diagram` through render and the visual check. Pass the Node list to step 3: a
   Node with one Edge in and one out that adds nothing is a layer to question.
3. **Review the shape and names.** Run `review-diff-lens` twice in parallel, once with
   `simplicity` and once with `naming`. Give each the worktree, the range, the Node
   list, and the paths of the repository's agent instructions and standards docs.
4. **Verify each finding.** Open its `path:line` in the worktree. Keep it only when the
   quoted code matches, the line is in the diff (or it is marked outside the diff), and
   the repository's own conventions do not already allow it. For a rename of an export,
   run `find-call-sites` and note the caller count. Merge duplicates.
5. **Write the table** of renames, simplifications, and folder moves, in the format in
   [references/review-output.md](references/review-output.md).
6. **Write the line comments** in the same reference's format. With a live Hunk session
   on the worktree, place them as one `hunk session comment apply` batch and navigate to
   the first one. With no session, give the user the `hunk diff` command to open one.
   Then ask whether to post one root-level PR comment, line-by-line PR comments, or
   nothing. Never post without that answer. Post exactly the choice, as the reference
   shows. A branch with no PR has nothing to post to; say so and skip the question.

## Verification

- The user's checkout is on the branch, with the `git status --short`, recorded in step 1.
- `git -C <worktree> rev-parse HEAD` is the head commit that was reviewed.
- Every table row and line comment was re-read at its `path:line` in step 4.
- Skema: each render exited 0 with no unfixed label warning. Otherwise, say the text
  fallback was used.
- Hunk: `hunk session comment list --json` shows each note at its file and line.
- Posted: the URL `gh` returned, and for a review, as many comments as were sent.

## Report

End with:

```markdown
Reviewed: <PR or branch> at <short sha>, <files> files, +<added> −<deleted>
Worktree: <path> (remove with `git worktree remove <path>`)
Diagrams: <file paths, or inline>
Findings: <renames> renames, <simplifications> simplifications, <moves> folder moves
Posted: <URL, or not posted>
Missing tools: <names, or none>
```
