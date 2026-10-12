# Terms: <feature display name>

Status: planned

The naming contract for this feature. One row per term that crosses a boundary:
anything exported, published, configured, or sent on the wire. Private helpers stay out.
The technical spec owns shapes; this file owns names, meanings, and surfaces.

| Term | Meaning | Kind | Owner | Model | Functions | Module | Wire name | Status | Alias of |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `<Term>` | `<one sentence>` | model / behavior / contract / module / config / actor | frontend / backend / infrastructure | `<TypeName>` | `<verbFirstFunction>` | `<project-name>` | `<tool_name, EVENT_NAME, ENV_VAR>` | existing / new / renamed / retired | `<old name>` |

Rules:

- Discovery adds `existing` rows from exported symbols in scope before anything new is named.
- PRD review adds `new` rows with meaning only; planning fills the surfaces.
- Each requirement, packet, and PR note names the rows it uses.
- A rename edits the row and records the old name in Alias of. A meaning change is a scope change.
- Function names are verb-first sentences. Model names are nouns. Modules are named after the term.
- Terms shared across features are promoted to `product/GLOSSARY.md` at final report.
