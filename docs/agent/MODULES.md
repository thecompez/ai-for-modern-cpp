# C++ Module Decisions

Use this guide for module creation, interface changes, implementation movement,
or module-related review. Canonical rules: `MOD-*` and `BLD-*`.

## File Roles

| File | Allowed content |
|---|---|
| `.cppm` | Exported declarations, concepts, lightweight templates, small compile-time values |
| `.cpp` module implementation | Non-trivial algorithms, mutation, I/O, private behavior |
| `.cpp` executable | Composition, startup, top-level error translation |
| `.hpp` | Explicit third-party, ABI, C API, or Qt MOC compatibility boundary only |
| `.h` | Forbidden unless required by an external ecosystem |

## Standard Library Policy

Project-owned C++ modules are required. Experimental standard-library modules
are not part of the supported architecture.

- Use minimal standard headers for every standard-library dependency.
- In `.cppm` and named-module implementation units, place those headers in the
  global module fragment between `module;` and the named module declaration.
- Never write `import std;`.
- Never introduce a compile definition that switches between `import std` and
  headers.
- Do not replace `.cppm` files with project headers.

This keeps module ownership and dependency scanning while avoiding experimental
standard-library metadata, compiler gates, and toolchain-specific BMIs.

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
module;

#include <string>
#include <string_view>

export module project.identity;

export namespace project::identity {

/**
 * @brief Represents a validated user identifier.
 */
class UserId final {
public:
    explicit UserId(std::string value);
    [[nodiscard]] std::string_view value() const noexcept;

private:
    std::string m_value;
};

}
```

```cpp
module;

#include <stdexcept>
#include <string>
#include <string_view>
#include <utility>

module project.identity;

namespace project::identity {

UserId::UserId(std::string value)
    : m_value(std::move(value))
{
    if (m_value.empty()) {
        throw std::invalid_argument{"User identifier must not be empty."};
    }
}

std::string_view UserId::value() const noexcept
{
    return m_value;
}

}
```

`module;` begins the global module fragment. Including a standard header after
`export module project.identity;` or `module project.identity;` would place its
declarations in the named module purview and is forbidden.

Ordinary non-module `.cpp` entry points include the minimal standard headers at
the top of the translation unit, then import project modules.

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

set_property(TARGET project_identity PROPERTY CXX_SCAN_FOR_MODULES ON)
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
4. Are standard headers in the global module fragment?
5. Is `import std;` absent?
6. Does the namespace mirror the dotted module identity?
7. Is the interface registered in the CMake module file set?
8. Do tests consume the public module instead of implementation files?
