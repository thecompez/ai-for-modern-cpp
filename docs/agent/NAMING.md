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
| Boolean | predicate-style lowerCamelCase | `isReady`, `hasValue` |
| QML type/file | PascalCase | `PrimaryActionButton.qml` |
| QML id/property/signal | lowerCamelCase | `resultDisplay`, `hasError` |

Multiword identifiers preserve their word boundaries. Acronyms are treated as
words: `HttpClient`, `UserId`, and `parseJson`.

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
- Unprefixed private members such as `myMember` or `my_member`.
- snake_case enumerators such as `empty_expression`.
- Reserved identifiers such as `__value`, `_Type`, or global `_value`.
- Keyword workarounds such as `delete_`, `class_`, or `concept_`.
- Single-letter public names outside established mathematical conventions.
- Abbreviations that hide the domain concept.

## Canonical Enum And Member Shape

Correct:

```cpp
enum class ErrorCode {
    EmptyExpression,
    InvalidToken
};

class AppState final {
private:
    std::string m_expressionText;
    ErrorCode m_errorCode {ErrorCode::EmptyExpression};
};
```

Incorrect:

```cpp
enum class ErrorCode {
    empty_expression,
    invalid_token
};

class AppState {
private:
    std::string my_member;
    ErrorCode error_code_;
};
```

See `SYNTAX_AND_STYLE.md` for the complete syntax contract.

## Rename Decision

Rename when the current name causes incorrect ownership, ambiguity, or policy
violation. Do not rename public APIs as incidental cleanup during unrelated
work. A necessary public rename must update callers, tests, documentation, and
release notes together.
