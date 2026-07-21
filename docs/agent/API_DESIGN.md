# Public API Design

Use this guide before exporting a symbol or changing a public contract.
Canonical rules: `API-*`, `ERR-*`, and `RES-*`.

## Contract Checklist

Every public operation should make these facts visible:

```text
Input ownership:
Input lifetime:
Output ownership:
Optionality:
Recoverable failures:
Exceptional failures:
Thread-safety assumptions:
Complexity or blocking behavior when important:
```

## Type Selection

| Meaning | Preferred type |
|---|---|
| Owned text | `std::string` |
| Read-only non-owning text | `std::string_view` with clear lifetime |
| Non-owning contiguous sequence | `std::span` |
| Optional value | `std::optional<T>` |
| Recoverable result | `std::expected<T, E>` |
| Closed alternatives | `std::variant<...>` |
| Time and duration | `std::chrono` types |
| Filesystem path | `std::filesystem::path` |

Do not use a raw pointer or `bool` when the real contract is ownership,
optionality, or a structured failure.

## Strong Types

Use a dedicated value type when primitive values have invariants, units, or
distinct domain meaning. Validate during construction or through an explicit
factory returning `std::expected`.

## Concepts

Use a concept when a public template relies on a meaningful operation set or
type category.

```cpp
template <typename T>
concept TextRenderable =
    requires(const T& value) {
        { value.toText() } -> std::convertible_to<std::string>;
    };
```

Avoid unconstrained public templates whose errors appear deep inside an
implementation. Also avoid concepts that merely rename `typename` without
improving diagnostics or safety.

## Documentation

Exported APIs require English Doxygen comments that explain behavior,
invariants, ownership, and errors. Do not document obvious syntax while hiding
the actual contract.

## Compatibility

Treat public API changes as repository-level decisions. Prefer additive or
migration-friendly changes when compatibility matters. Do not preserve a bad
API blindly when the repository is still explicitly experimental; document the
decision either way.
