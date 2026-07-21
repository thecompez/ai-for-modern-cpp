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
module;

#if !APP_USE_IMPORT_STD
#include <string>
#include <string_view>
#endif

export module project.identity;

#if APP_USE_IMPORT_STD
import std;
#endif

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

#if !APP_USE_IMPORT_STD
#include <stdexcept>
#include <string>
#include <string_view>
#include <utility>
#endif

module project.identity;

#if APP_USE_IMPORT_STD
import std;
#endif

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

`module;` begins the global module fragment. Standard-library headers belong
there when the effective toolchain cannot provide `import std`; including them
after `export module project.identity;` would attach declarations to the named
module purview and is forbidden. When `APP_USE_IMPORT_STD` is true, the fragment
is empty and the named module imports `std` normally.

The compatibility macro is a target-provided build decision, not a
source-by-source preference. Every producer and consumer of a module must see
the same value. Ordinary non-module `.cpp` entry points may conditionally
choose `import std;` or the minimal standard headers directly, but project
modules and their CMake `CXX_MODULES` registration do not change.

This fallback applies only to standard-library delivery. It does not authorize
project-owned headers, duplicate declarations, or a parallel legacy source
tree.

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
