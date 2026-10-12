# Published Review Surface

Keep run machinery under `.lore-flow/`. Mint a small review pack outside that directory
so people never hunt through gitignored files.

## Two layers

- **Published pack**: the human review surface. Keep it short, named, and current.
  Approval checkpoints present these files first.
- **Run machinery**: discovery dumps, packets, reviews, versions, aliases, and recovery
  evidence under `.lore-flow/runs/<run-id>/`. Gitignore that directory in the
  target repository. Do not ask reviewers to open it unless they need evidence.

## Published-pack mode

The preset's `publishedPack` value, recorded in `run.md` at intake, decides where the
pack lives:

- `committed`: written under the target repository and committed with the planning
  branch; versions are Git blob hashes.
- `local`: written under the target repository but excluded from Git (the repository's
  `.git/info/exclude` or equivalent); versions are SHA-256 hashes recorded in the index.
  Builders refresh the planning worktree copy, never a build worktree copy.
- `none`: no pack is minted; the glossary lives at the run root and checkpoints present
  run artifacts directly.

Ask for the mode at intake when the preset leaves it unset or the repository has a
convention that contradicts it. Never commit the pack in a repository whose rules exclude
feature docs.

If discovery finds an existing feature-doc convention, use it. Otherwise write:

```text
docs/features/<feature-slug>/
├── README.md
├── technical-spec.md
├── architecture-overview.md
├── glossary.md
├── sequence.md
└── prs/
    └── <nn>-<domain>-<purpose-slug>.md
```

## Required published files

Every file carries a `Status:` line directly under its title with one of `planned`,
`in-progress`, `shipped`, `pivoted`, or `abandoned`. Realignment rewrites it; a pack that
describes work that was not built says so on its first line.

### Systems summary — `README.md`

One page. State the change in plain language, the systems touched, the end-state
picture, and links to the spec, overview, glossary, sequence, and each PR note. No IDs
in the lede. No run-folder paths except an optional evidence footnote.

### Technical spec — `technical-spec.md`

Full behaviors that come out of the PRD: actors, triggers, acceptance, failures,
empty/loading/retry cases, in-scope, out-of-scope, and named model/contract/state/
behavior requirements. Every requirement carries `Today:` and `After:` lines and names
the glossary rows it uses. A `## Terms` section near the top lists the rows this spec
introduces or relies on. This is the committed spec, not a dump of frontier IDs. It is
the only requirements document; there is no run-folder copy.

### End-state architecture — `architecture-overview.md`

Describe the system after this work lands. Include only:

- `## Today → After` as the first section: what exists now, what will exist, in at most
  ten lines
- very simple object models: name, fields, invariants, using glossary names
- contracts: inputs, outputs, errors, owners
- justified Mermaid diagrams per [diagram-policy.md](diagram-policy.md)

Give every model, contract, and diagram a heading so PR notes can link to that facet.
Do not bury the end state in per-area draft files. Domain drafts may exist in the run
folder as evidence; the published overview is the architecture people read and has no
run-folder copy.

### Feature glossary — `glossary.md`

The naming contract: one row per boundary-crossing term with its meaning, kind, owner,
model, functions, module, wire name, status, and alias. Created at intake from
`templates/feature/glossary.md`, seeded by discovery with existing rows, extended by
PRD review and planning, reconciled against exports at final report.

### Sequence — `sequence.md`

The PR order, dependency DAG or single-PR statement, and a table of PR notes with
links and display names. This is the sequence people approve. Packets stay in the run
folder.

### Per-PR notes — `prs/<nn>-<domain>-<purpose-slug>.md`

Each note is one screen or less. It must:

- open with the five-line Before / After / See it / Files / Checks block
- name the PR by its single display name and its slice of the end state
- list the glossary rows it implements
- link to the overview facets it implements
- include terse pseudo-code or a small nominal-flow diagram for this PR only
- state local/hosted config duties when infrastructure
- include the exact frontend no-op note when that exception applies

Do not copy the build packet, test matrix, or worktree policy here.

## When to mint

1. At intake: create `glossary.md` from the template.
2. After requirements planning: write or refresh `README.md`, `technical-spec.md`,
   `architecture-overview.md`, and glossary rows before the requirements approval
   checkpoint.
3. After PR sequencing: write or refresh `sequence.md` and every `prs/*.md` before the
   sequence approval checkpoint.
4. During a PR build: update only that PR note and any overview facet the packet owns.
5. During realignment: refresh only published files reached by the change, including the
   `Status:` line and the `Changed since` sections. Keep prior committed versions in Git
   history; do not silently rewrite.
6. At any terminal state: set every `Status:` line and say in the README where the
   accurate end-state description now lives.

Present the published pack, not the run folder, at every human approval checkpoint.
