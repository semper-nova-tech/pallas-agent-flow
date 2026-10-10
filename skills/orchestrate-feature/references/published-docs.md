# Published Review Surface

Keep run machinery under `.lore-flow/`. Mint a small committed review pack
outside that directory so people never hunt through gitignored files.

## Two layers

- **Published pack**: the human review surface. Commit it. Keep it short, named, and
  current. Approval checkpoints present these files first.
- **Run machinery**: discovery dumps, packets, reviews, versions, aliases, and recovery
  evidence under `.lore-flow/runs/<run-id>/`. Gitignore that directory in the
  target repository. Do not ask reviewers to open it unless they need evidence.

If discovery finds an existing feature-doc convention, use it. Otherwise write:

```text
docs/features/<feature-slug>/
├── README.md
├── technical-spec.md
├── architecture-overview.md
├── sequence.md
└── prs/
    └── <nn>-<domain>-<purpose-slug>.md
```

Recommend adding `.lore-flow/` to the target repository `.gitignore`.

## Required published files

### Systems summary — `README.md`

One page. State the change in plain language, the systems touched, the end-state
picture, and links to the spec, overview, sequence, and each PR note. No IDs in the
lede. No run-folder paths except an optional evidence footnote.

### Technical spec — `technical-spec.md`

Full behaviors that come out of the PRD: actors, triggers, acceptance, failures,
empty/loading/retry cases, in-scope, out-of-scope, and named model/contract/state/
behavior requirements. This is the committed spec, not a dump of frontier IDs. It is
the only requirements document; there is no run-folder copy.

### End-state architecture — `architecture-overview.md`

Describe the system after this work lands. Include only:

- a short current-to-end-state delta
- very simple object models: name, fields, invariants
- contracts: inputs, outputs, errors, owners
- justified Mermaid diagrams per [diagram-policy.md](diagram-policy.md)

Give every model, contract, and diagram a heading so PR notes can link to that facet.
Do not bury the end state in per-area draft files. Domain drafts may exist in the run
folder as evidence; the published overview is the architecture people read and has no
run-folder copy.

### Sequence — `sequence.md`

The PR order, dependency DAG or single-PR statement, and a table of PR notes with
links. This is the sequence people approve. Packets stay in the run folder.

### Per-PR notes — `prs/<nn>-<domain>-<purpose-slug>.md`

Each note is one screen or less. It must:

- name the PR and its slice of the end state
- link to the overview facets it implements
- include terse pseudo-code or a small nominal-flow diagram for this PR only
- state local/hosted config duties when infrastructure
- include the exact frontend no-op note when that exception applies

Do not copy the build packet, test matrix, or worktree policy here.

## When to mint

1. After requirements planning: write or refresh `README.md`, `technical-spec.md`, and
   `architecture-overview.md` before the requirements approval checkpoint.
2. After PR sequencing: write or refresh `sequence.md` and every `prs/*.md` before the
   sequence approval checkpoint.
3. During a PR build: update only that PR note and any overview facet the packet owns.
4. During realignment: refresh only published files reached by the change. Keep prior
   committed versions in Git history; do not silently rewrite.

Present the published pack, not the run folder, at every human approval checkpoint.
