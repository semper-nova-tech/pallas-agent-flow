# Diagram Policy

Use diagrams only when they materially clarify meaningful relationships. Follow a
repository-native format when discovery finds an established documentation convention.
Otherwise, when the run's `tools` field records Skema, draw each design, domain model,
and PR sequence diagram as a Skema Manifest at `diagrams/<diagram-slug>.json` in the
published pack, render its SVG beside it with `skema render`, and embed the SVG under
the diagram's heading. Open each new diagram per [terminal-tools.md](terminal-tools.md).
Without Skema, embed Mermaid blocks in the Markdown, not separate image artifacts.
Use [human-readable-output.md](human-readable-output.md) for diagram labels and paths.

## Required triggers and homes

- A cross-system or domain-boundary change requires a current or proposed context or
  component flowchart in published `architecture-overview.md`.
- Two or more new or changed models with relationships between them require a domain
  model diagram in the overview.
- A multi-step API, event, or job interaction requires a sequence diagram in the
  overview or the owning published PR note, usually backend.
- A non-trivial lifecycle or UI/server state change requires a state diagram in the
  overview or the owning frontend/backend PR note.
- An infrastructure topology, network, resource, or runtime change requires a deployment
  or topology flowchart in the overview. Show local and hosted differences when material.
- More than one planned PR requires a dependency DAG in published `sequence.md`.
  For one PR, state that no dependency diagram is needed.
- A PR note may add a small nominal-flow diagram for that PR's slice only.
- Add an ADR diagram only when the decision is hard to understand without it.

One diagram may satisfy multiple triggers. Record `none` when no trigger is justified.

## YAGNI guardrails

Do not diagram trivial field additions, single-step behavior, unchanged topology, or
content that merely repeats prose. Keep each diagram small and focused. Use names that
match the human-readable requirement and contract names, label assumptions, and never
invent undiscovered components. IDs remain hidden node metadata where practical; labels
must not require users to decode them.

## Mermaid safety

Prefer only `flowchart`, `sequenceDiagram`, and `stateDiagram-v2`. Use simple, stable
syntax and camelCase or PascalCase IDs without spaces. Quote labels containing
punctuation or special characters. Avoid reserved IDs such as `end`, HTML, angle
brackets, explicit colors or styles, and click directives.

Validate syntax and rendering with repository tooling when available. Otherwise record a
manual syntax review against these rules and do not claim rendered validation. A Skema
diagram is validated by a `skema render` that exits 0 with no unexplained warnings.

## Lifecycle

Planning selects each required diagram before the requirements approval checkpoint and
records its purpose, type, home, and source requirements. Embed those diagrams in the
published architecture overview. Sequencing puts the PR DAG in published `sequence.md`
before sequence approval. Owning PRs update overview facets and PR notes they own.

Reviewers challenge missing, inaccurate, speculative, duplicated, or stale diagrams
without requesting decorative ones. Realignment refreshes only impacted diagrams and
preserves unaffected diagrams. Rename-only changes use aliases to refresh affected labels
without redesigning the diagram.
