# C++ Module Decisions

Use this guide for module creation, interface changes, implementation movement,
or module-related review. Canonical rules: `MOD-*` and `BLD-*`.

## File Roles

| File | Allowed content |
|---|---|
| `.cppm` | Exported declarations, concepts, lightweight templates, small compile-time values |
| `.cpp` module implementation | Non-trivial algorithms, mutation, I/O, private behavior |
| `.cpp` executable | Composition, startup, top-level error translation |
| `.hpp` | Explicit third-party, ABI, C API, or textual compatibility boundary only |
| `.h` | Forbidden unless required by an external ecosystem |

## Interface Test

Keep code in `.cppm` only when an importer must see it to compile or when the
implementation is genuinely trivial.

Move code to `.cpp` when it:

- performs I/O or mutation;
- contains a long algorithm;
- introduces platform branches;
- depends on private helpers;
- would cause unrelated importers to recompile frequently;
- exposes implementation choices rather than contract.

## Canonical Shape

```cpp
export module project.identity;

import std;

export namespace project::identity {

/**
 * @brief Represents a validated user identifier.
 */
class UserId final {
public:
    explicit UserId(std::string value);
    [[nodiscard]] auto value() const noexcept -> std::string_view;

private:
    std::string m_value;
};

}
```

```cpp
module project.identity;

import std;

namespace project::identity {

UserId::UserId(std::string value)
    : m_value(std::move(value))
{
    if (m_value.empty()) {
        throw std::invalid_argument{"User identifier must not be empty."};
    }
}

auto UserId::value() const noexcept -> std::string_view
{
    return m_value;
}

}
```

## CMake Registration

```cmake
target_sources(project_identity
    PUBLIC
        FILE_SET CXX_MODULES
        FILES
            src/project/identity.cppm
    PRIVATE
        src/project/identity.cpp
)
```

The interface belongs in a `CXX_MODULES` file set. The implementation is a
normal private source. Consumers link the target and import the module.

## Re-exports And Facades

A facade module may re-export cohesive public modules when it provides a stable
entry point. Do not create a facade merely to hide unclear dependency design.

## Review Questions

1. Does the module own one recognizable responsibility?
2. Can an importer understand the public contract without the implementation?
3. Are heavyweight operations outside the interface?
4. Does the namespace mirror the dotted module identity?
5. Is the interface registered in the CMake module file set?
6. Do tests consume the public module instead of implementation files?
