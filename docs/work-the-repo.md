# Working the repo efficiently (lightweight work)

For anything that doesn't warrant the full Pallas flow (PRD, glossary,
discovery, PR sequencing): investigations, audits, maintenance, dependency
bumps, CI triage, doc fixes, and small enhancements that are a one- or
few-file change with an obvious contract — not a multi-PR feature needing
its own glossary rows. Goal: keep the expensive model's context small,
delegate grunt work, only escalate to the strongest model at real decision
points.

If a "small enhancement" turns out to touch shared contracts, spans several
PRs, or needs its own glossary entries, that's the signal to bail out to the
full flow (`orchestrate-feature` / `product-spec` / `plan-requirements`)
instead of forcing it through this lighter path.

## The idea, mapped onto what's actually available here

Anthropic's trick (pasted verbatim below) is: tier work by model fit —
a mid model drives the session, a cheap model swarms search/grep/audit in
parallel, a strong model only signs off at real decision points. Same shape,
applied to this environment's actual tools:

- **Main session**: default model, drives the session, writes/applies changes.
- **Advisor-tier escalation**: only pull the strongest available model
  (`claude-opus-5-5-medium`) at three moments — before a plan locks, when the
  same error shows up twice, before calling it done. Not for routine work.
- **Cheap/parallel delegation** (instead of a dedicated cheap model, which
  isn't available here — use tool calls and subagents):
  - Plain `Grep` / `Glob` / `Read` first. Cheaper than any subagent or model;
    use it whenever the question has a direct answer.
  - `explore` subagent for repo mapping / "where is X" when the repo is
    unfamiliar or the search is fuzzy (pick quick/medium/very thorough).
  - `generalPurpose` subagent for call-site sweeps when not confident a quick
    grep will find every match.
  - `ponytail` subagent to cross-check a diff or plan for omissions/
    regressions before declaring done — closest equivalent to the "audit"
    role.
  - `best-of-n-runner` when a check needs its own worktree so it never
    touches the working branch — closest equivalent to the isolation
    requirement on "audit".
  - `bugbot` / `security-review` subagents only when explicitly requested.
- **Model selection**: only override the default when the user explicitly
  asks for a model, using a slug from `available_subagent_models`. There is
  no cheap/Haiku-tier slug in this environment — route cheap work to direct
  tool calls instead of a dedicated cheap model.
- **No JEV-style micro-fork router exists here.** The practical equivalent:
  let deterministic tool calls (Grep/Glob/Read, git plumbing) make the
  which-file / which-tool / retry-or-stop calls directly, with no model in
  the loop at all.

## Checklist for a lightweight session

1. Scope the ask in one line before touching anything.
2. Try `Grep`/`Glob`/`Read`/git directly first — no subagent, no model, if it
   answers the question.
3. If the repo is unfamiliar or the search is fuzzy, delegate to `explore`
   rather than burning main-session turns on trial-and-error search.
4. For call-site sweeps tied to a bug fix, delegate to `generalPurpose`
   rather than doing it ad hoc in the main session.
5. Make the change in the main session.
6. Before calling it done, run one cross-check — `ponytail`, or
   `best-of-n-runner` in an isolated worktree if the check could touch files.
7. Reserve the strongest model for: plan sign-off, a stuck/repeated error, or
   the final done-call. Everything else stays on the default tier.

---

## Source (pasted verbatim, Claude Code-specific, kept for reference)

THIS IS AN ACTUAL F*CKING GOLDMINE

Anthropic just shared one of the best tricks for Claude Code.

The idea: run Sonnet, Haiku 5.5 and Opus 5.5 at once, each one doing only the job it's best at.

Better results and way fewer tokens, because every task lands on the right model.

You just launch Claude Code like this:

claude --model sonnet --advisor opus

here's the split:

→ Sonnet 5.5 runs the session, writes the code and applies the fixes
→ Haiku 5.5 swarms the repo in parallel: search, grep and diff audits
→ Opus 5.5 stays on call as advisor for the big calls and signs off on the diff
→ you stop burning Opus context on work that doesn't need it

Opus only steps in at three moments:

→ before a plan locks
→ when the same error shows up twice
→ before calling it done

Sonnet builds. Haiku swarms. Opus reviews.

JEV engineering is the same move one layer down: the forks that need no thinker (which file, which tool, retry or stop) go to JEV in milliseconds, and the big models only see the ones that split

the full tree
> Sonnet 5.5 runs the main session and coordinates the work
> search maps the repo on Haiku 5.5, read-only
> grep finds call sites on Haiku 5.5 in its own context
> audit checks the diff on Haiku 5.5 in a throwaway worktree
> Opus 5.5 on call as advisor, reviews the synthesized diff before sign-off
> JEV routes micro-forks in milliseconds

paste the tree and this prompt into Claude Code ↓

"Reconfigure my Claude Code setup around this tree:
1. Run the main session on Sonnet 5.5 with Opus 5.5 as advisor.
2. Create three Haiku 5.5 subagents in .claude/agents: search (maps the repo), grep (finds call sites), audit (checks the diff).
3. Set isolation: worktree on audit so its checks never touch my working branch.
4. Add one rule to CLAUDE.md: delegate every repo search and test run to the Haiku 5.5 subagents to keep the main context small.
5. Route fast deterministic forks (tool choice, path selection, retries) through JEV.
Show me every change as a diff first. No edits until I say go."

↳ http://code.claude.com/docs/en/sub-agents
