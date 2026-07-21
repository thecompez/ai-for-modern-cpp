# Naming Decisions

Names are architecture. They should tell an agent what a symbol owns and where
it belongs. Canonical rules: `NAM-*`.

## Naming Matrix

| Entity | Form | Example |
|---|---|---|
| Module | dotted lowercase | `project.identity` |
| Namespace | module identity with `::` | `project::identity` |
| Type or concept | PascalCase | `RepositoryName`, `TextRenderable` |
| Function | lowerCamelCase | `makePolicySummary` |
| Parameter/local | lowerCamelCase | `repositoryName` |
| Private member | `m_` + lowerCamelCase | `m_repositoryName` |
| `enum class` enumerator | PascalCase | `Configure`, `Build`, `Test` |
| File | filesystem-friendly | `project_identity.cppm` |

## Module Naming Test

A good module name answers: "Which stable domain capability does this own?"

Good:

```text
project.identity
project.search
project.configuration
engine.plugin
company.billing
```

Bad:

```text
project.identity_utils
project.common
helpers
misc
project.stuff
```

## Forbidden Identifier Shapes

- Trailing-underscore project members such as `value_`.
- Reserved identifiers such as `__value`, `_Type`, or global `_value`.
- Keyword workarounds such as `delete_`, `class_`, or `concept_`.
- Single-letter public names outside established mathematical conventions.
- Abbreviations that hide the domain concept.

## Rename Decision

Rename when the current name causes incorrect ownership, ambiguity, or policy
violation. Do not rename public APIs as incidental cleanup during unrelated
work. A necessary public rename must update callers, tests, documentation, and
release notes together.
