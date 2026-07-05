# AGENTS.md

# AI Agent Guide for Modern C++ Repositories

This file is the canonical instruction guide for AI coding agents working in this repository.

Every agent, including Claude Code, Codex, GitHub Copilot, and other coding agents, must read this file before making changes.

The goal of this repository is to maintain a modern, safe, testable, module-based C++ codebase aligned with the current direction of ISO C++.

This guide is intentionally strict. Its purpose is to prevent AI agents from producing legacy C++, fake validation reports, unsafe ownership patterns, or broad unrelated rewrites.

Primary references:

- ISO C++ Core Guidelines: https://isocpp.org/guidelines
- C++ Core Guidelines source: https://github.com/isocpp/CppCoreGuidelines
- C++ language status: https://isocpp.org/std/status
- CMake documentation: https://cmake.org/cmake/help/latest/

---

## 1. Agent Operating Principles

Agents must optimize for correctness, safety, maintainability, and verifiability.

Before editing code, the agent must:

1. Read the relevant existing files.
2. Identify the owning subsystem.
3. Understand the module boundary.
4. Make the smallest correct change.
5. Build.
6. Test.
7. Report exact results.

Agents must not:

- Guess project behavior without reading code.
- Invent successful build or test results.
- Hide failing tests.
- Replace modern C++ with legacy patterns.
- Make broad formatting-only changes.
- Modify unrelated files.
- Add new dependencies without a strong reason.
- Ignore compiler warnings introduced by the change.

---

## 2. Toolchain Policy

The primary development path assumes a recent toolchain with strong support for modules, `import std`, concepts, and current C++26 features.

Preferred primary compiler:

```text
Clang 22 or newer
```

Supported fallback compilers may be used only when the requested feature set works correctly:

```text
Clang 18.1.2+     minimum for practical module experiments
MSVC 14.36+       when module support is verified
GCC 15+           when module and standard library support are verified
```

The preferred generator is:

```text
Ninja
```

The preferred CMake version is:

```text
CMake 4.3+
```

Minimum CMake baseline for this repository family:

```cmake
cmake_minimum_required(VERSION 3.30)
```

If the active compiler, standard library, CMake version, or generator cannot support the requested modern C++ feature, the agent must fail clearly or use the repository-provided fallback option.

The agent must not silently downgrade the code style.

---

## 3. Language Standard Policy

This repository targets C++20 or newer.

Preferred standard order:

1. C++26 when available.
2. C++23 when C++26 is not available.
3. C++20 as the minimum acceptable baseline.

New code must not be written in legacy C++ style.

Required modern C++ features when appropriate:

- Modules.
- Concepts.
- Compile-time constraints.
- `constexpr`.
- `consteval` when useful.
- `constinit` for stable static initialization.
- Ranges.
- Coroutines only when they simplify asynchronous control flow.
- `std::expected` or the project equivalent for recoverable errors.
- `std::span` for non-owning contiguous views.
- `std::string_view` for read-only string parameters with clear lifetime.
- `std::optional` for optional values.
- `std::variant` for closed alternatives.
- `std::chrono` for time.
- `std::filesystem` for paths.
- RAII for ownership and cleanup.
- Strongly typed enums.

Legacy patterns are not allowed by default.

The following are discouraged by default and require either explicit user request, a low-level systems reason, or a documented compatibility boundary:

- Raw owning pointers.
- Manual `new` and `delete`.
- C-style arrays for owned storage.
- C-style casts.
- Hidden global mutable state.
- Macro-driven business logic.
- New `.h` files.
- New `.hpp` files unless required for dependency boundaries or compatibility.
- Classic `.h` / `.cpp` architecture for new internal project code.

When such a pattern is truly necessary, the agent must document why it is necessary in the code review summary.

Acceptable reasons include:

- Low-level allocator implementation.
- ABI boundary.
- C API interop.
- Operating system API boundary.
- Third-party library compatibility.
- Embedded or performance-critical memory layout.
- Placement-new or custom lifetime management in a carefully isolated type.
- Compiler or standard library workaround.
- Explicit user instruction.

Even in those cases, isolate the unsafe or low-level pattern behind a small, tested, RAII-safe abstraction.

---

## 4. File Extension Rules

The repository uses the following extension policy:

```text
.cppm   C++ module interface / declaration
.cpp    C++ module implementation or executable entry point
.hpp    Optional dependency boundary, compatibility header, or third-party adapter
.h      Not allowed for new project files unless explicitly requested or required by external tooling
```

Declaration must live in `.cppm`.

Implementation must live in `.cpp`.

If a dependency cannot be imported as a module and requires textual inclusion, isolate it behind `.hpp`.

Do not create `.h` files for new code unless the user explicitly requests it or the external ecosystem requires that exact extension.

If a `.h` file is unavoidable, explain why in the final report.

---

# Module Naming Rule
- Module names must be dotted, lowercase, stable, domain-oriented, and without `_`.
- Good: `app.userid`, `project.search`, `project.localization`, `company.core`, `engine.plugin`, `core.memory`.
- Bad: `app.user_id`, `project.search_engine`, `core.memory_utils`.
- Avoid vague module names like `utils`, `helpers`, `common`, and `misc` unless the project already requires them.

# Naming
- Types/classes/concepts: PascalCase.
- Functions, parameters, and local variables: lowerCamelCase.
- Private/protected non-static data members: `m_` prefix.
- Good members: `m_data`, `m_size`, `m_value`, `m_name`.
- Bad members: `data_`, `size_`, `value_`, `name_`.
- `enum class` enumerators must be PascalCase.
- Good: `enum class HttpMethod { Unknown, Get, Post, Put, Patch, Delete };`
- Bad: `enum class HttpMethod { get, post, delete_, unknown };`
- Avoid workaround names like `delete_`, `class_`, `concept_`, `template_`, or `del`.
- Avoid reserved or project-forbidden identifiers like `__name`, `_Name`, global `_name`, `name_`, and `Name_`.
- 
## 5. Naming Policy

Use dot-separated C++ module names.

Correct:

```cpp
export module modern.cpp.agent;
import modern.cpp.agent;
```

Incorrect:

```cpp
export module modern_cpp_agent;
import modern_cpp_agent;
```

Use C++ namespaces that mirror the module identity.

Correct:

```cpp
export namespace modern::cpp::agent {
}
```

Incorrect:

```cpp
export namespace modern_cpp_agent {
}
```

Private class data members must use the `m_` prefix.

Correct:

```cpp
private:
    std::string m_value;
```

Incorrect:

```cpp
private:
    std::string value_;
```

File names may stay filesystem-friendly:

```text
modern_cpp_agent.cppm
modern_cpp_agent.cpp
```

The module identity inside the code is the important part:

```cpp
export module modern.cpp.agent;
```

---

## 6. Module Architecture

New production code must use modules by default.

Preferred structure:

```text
src/
  project/
    project.cppm
    project.cpp
    project_platform.cppm
    project_platform_macos.cpp
    project_platform_windows.cpp
    project_platform_linux.cpp
    project_compat.hpp
```

Example declaration module:

```cpp
export module project.core;

import std;

export namespace project::core {

/**
 * @brief Represents a validated application name.
 */
class ApplicationName final {
public:
    /**
     * @brief Creates an application name from a non-empty string.
     */
    explicit ApplicationName(std::string value);

    /**
     * @brief Returns the stored application name.
     */
    [[nodiscard]] auto value() const noexcept -> std::string_view;

private:
    std::string m_value;
};

}
```

Example implementation unit:

```cpp
module project.core;

import std;

namespace project::core {

ApplicationName::ApplicationName(std::string value)
    : m_value(std::move(value))
{
    if (m_value.empty()) {
        throw std::invalid_argument{"Application name must not be empty."};
    }
}

auto ApplicationName::value() const noexcept -> std::string_view
{
    return m_value;
}

}
```

Do not put large algorithms or platform-specific code inside exported module interfaces.

---

## 7. Declaration And Implementation Rule

Every non-trivial exported type must have:

- Declaration in `.cppm`.
- Implementation in `.cpp`.

Acceptable in `.cppm`:

- Public declarations.
- Concepts.
- Small value types.
- Small `constexpr` functions.
- Doxygen comments.
- Compile-time constants.
- Lightweight templates that must be visible to importers.

Not acceptable in `.cppm`:

- Long algorithms.
- File system mutation logic.
- Network logic.
- Database logic.
- Platform-specific branches.
- UI behavior code.
- Test-only helpers.
- Large implementation details.

---

## 8. Concepts And Compile-Time Policy

Use concepts to express compile-time contracts whenever they make an API safer, clearer, or more self-documenting.

Concepts are required when:

- A template expects a specific operation set.
- A generic algorithm would otherwise fail with unreadable substitution errors.
- A public template API needs a clear contract.
- A type category matters to correctness.
- Compile-time validation prevents runtime misuse.

Good:

```cpp
template <typename T>
concept StringLike =
    requires(T value) {
        { std::string_view{value} } -> std::same_as<std::string_view>;
    };
```

Good:

```cpp
template <typename T>
concept PathLike =
    requires(T value) {
        { std::filesystem::path{value} };
    };
```

Bad:

```cpp
template <typename T>
auto parse(T value) -> Result;
```

Do not use concepts as decorative syntax.

Prefer compile-time enforcement over runtime checks when:

- The rule is knowable at compile time.
- The diagnostic can be made clear.
- Runtime flexibility is not required.

Use:

- `static_assert` for invariant checks.
- Concepts for template constraints.
- `constexpr` for compile-time computation.
- `consteval` for values that must be produced at compile time.
- `constinit` for static storage that must avoid dynamic initialization.

Example:

```cpp
template <typename T>
concept NonBooleanIntegral =
    std::integral<T> && !std::same_as<std::remove_cvref_t<T>, bool>;
```

If a runtime check is still required, keep it explicit and tested.

---

## 9. Public API Documentation

Every exported class, function, enum, concept, and public data structure must have Doxygen-style documentation.

Comments inside source code must be written in English.

Do not write Persian comments inside source code.

Example:

```cpp
/**
 * @brief Parses a strict semantic version string.
 *
 * The accepted format is `major.minor.patch`.
 */
[[nodiscard]] auto parseVersion(std::string_view text) -> std::expected<Version, ParseError>;
```

---

## 10. Error Handling

Prefer explicit error handling for recoverable failures.

Use:

- `std::expected` when the active standard library supports it.
- A project-local `Result<T, E>` equivalent when `std::expected` is unavailable.
- Exceptions for exceptional conditions, invariant violations, construction failure, or when the subsystem intentionally uses exceptions.

Do not:

- Swallow errors.
- Log and continue unless continuation is safe.
- Return fake success.
- Convert all errors into `bool`.
- Use exceptions as ordinary control flow for expected failures unless the subsystem explicitly does so.

---

## 11. Resource Management

Follow RAII.

Every acquired resource must be owned by a type that releases it deterministically.

This includes:

- Files.
- Sockets.
- Handles.
- Threads.
- Timers.
- Temporary directories.
- Locks.
- Platform resources.
- Allocated memory.

Manual resource management is allowed only in isolated low-level code where RAII is being implemented, not bypassed.

Good low-level pattern:

```cpp
class NativeHandle final {
public:
    explicit NativeHandle(void* handle) noexcept;
    ~NativeHandle();

    NativeHandle(const NativeHandle&) = delete;
    auto operator=(const NativeHandle&) -> NativeHandle& = delete;

    NativeHandle(NativeHandle&& other) noexcept;
    auto operator=(NativeHandle&& other) noexcept -> NativeHandle&;

private:
    void* m_handle {};
};
```

Do not use manual cleanup spread across multiple call sites.

---

## 12. Platform Boundaries

Use platform macros only at platform boundaries.

Allowed examples:

```cpp
#if defined(__APPLE__)
#if defined(_WIN32)
#if defined(__linux__)
#if defined(__FreeBSD__)
```

Do not scatter platform macros across business logic.

Preferred layout:

```text
project_platform.cppm
project_platform_macos.cpp
project_platform_windows.cpp
project_platform_linux.cpp
project_platform_freebsd.cpp
```

---

## 13. CMake Policy

Use modern CMake.

Minimum baseline:

```cmake
cmake_minimum_required(VERSION 3.30)
```

Preferred CMake for the primary path:

```text
CMake 4.3+
```

Use target-based configuration.

Good:

```cmake
target_compile_features(target_name PRIVATE cxx_std_26)
target_sources(target_name
    PUBLIC
        FILE_SET CXX_MODULES
        FILES
            src/project/project.cppm
    PRIVATE
        src/project/project.cpp
)
```

Avoid unless there is a documented compatibility reason:

```cmake
include_directories(...)
add_definitions(...)
set(CMAKE_CXX_FLAGS ...)
```

Use target-local alternatives:

```cmake
target_include_directories(...)
target_compile_definitions(...)
target_compile_options(...)
```

---

## 14. `import std` Policy

When the toolchain supports it, prefer:

```cpp
import std;
```

The repository may provide an option such as:

```cmake
option(PROJECT_ENABLE_IMPORT_STD "Enable C++26 import std support when available" ON)
```

If `import std` is enabled, configure:

```cmake
set(CMAKE_CXX_MODULE_STD ON)
set(CMAKE_CXX_SCAN_FOR_MODULES ON)
```

If the compiler, standard library, CMake version, or generator does not support `import std`, fail clearly or disable the option explicitly.

Do not silently pretend `import std` works.

### Standard Library Module Portability Note

When using `import std;`, do not assume C compatibility globals such as `stderr`, `stdin`, or `stdout` are available as unqualified global identifiers.

Correct:

```cpp
std::println("Test failure: {}", error.what());
```

Avoid in pure `import std;` examples:

```cpp
std::println(stderr, "Test failure: {}", error.what());
```

If standard C interop is required, isolate it through a compatibility boundary.

---


### Ranges Portability Note

Do not use `std::views::enumerate` in repository examples unless the active standard library is verified to support it.

Some recent Clang/libc++ combinations may compile C++26 modules but still not provide `std::views::enumerate`.

Prefer explicit indexed loops or stable range algorithms for template code that must build reliably.

## 15. Build Verification

After changing code, run the relevant build command.

Default:

```bash
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build --parallel
```

Do not claim the project builds unless the build command completed successfully.

If the build cannot be run, say so clearly.

---

## 16. Test Verification

After implementation changes, run tests.

Default:

```bash
ctest --test-dir build --output-on-failure
```

Do not claim tests pass unless they were actually run and passed.

If tests are missing, add tests when practical.

---

## 17. AI Loop Test Requirement

For non-trivial changes, follow this loop:

```text
Read existing code
Make the smallest correct change
Build
Run tests
Inspect failures
Fix
Build again
Run tests again
Summarize exact results
```

Do not stop after the first generated solution.

Do not hide failing tests.

Do not make broad unrelated rewrites.

---


---

## MCP Tooling Policy

MCP configuration is allowed, but it must be safe by default.

Repository-level examples should use:

```text
.mcp.example.json
docs/MCP.md
```

Local active configuration should use:

```text
.mcp.json
```

`.mcp.json` must be ignored by git when it may contain local paths, private endpoints, tokens, or machine-specific settings.

Agents must not add secrets to MCP configuration files.

Agents must not enable write-capable, deployment, payment, production database, or destructive tools unless the user explicitly requests them.

Preferred MCP permission order:

```text
1. Read-only filesystem context
2. Local git inspection
3. GitHub read access
4. Build/test helper tools
5. Write-capable tools only with explicit user intent
```

When MCP tools are used, the final report should mention which tool category was used and why.


## 18. Claude, Codex, And Copilot Compatibility

This repository should work well with multiple AI coding agents.

For Claude Code:

- `CLAUDE.md` must point to this file.
- `.claude/commands` may define repeatable workflows.
- Commands must require build and test verification.

For Codex:

- Keep instructions explicit, direct, and repository-local.
- Prefer concrete commands over vague process descriptions.
- Always state the expected file layout.
- Avoid relying on hidden context.

For GitHub Copilot:

- Keep public APIs documented.
- Keep modules and namespaces consistently named.
- Keep examples short and idiomatic.
- Avoid ambiguous naming patterns.

All agents must treat this file as the source of truth.

---

## 19. Commit And PR Rules

Commit messages should be precise.

Good:

```text
Add module-based version parser
Fix platform app data directory resolution
Add smoke test for configuration loader
```

Bad:

```text
Update code
Fix stuff
AI changes
```

Pull request summaries must include:

- What changed.
- Why it changed.
- How it was tested.
- Any known limitations.
- Any intentional low-level exceptions to the default safety rules.

---

## 20. Final Response Requirements For Agents

When finishing a task, report:

- Files changed.
- What changed.
- Build command used.
- Test command used.
- Result of build.
- Result of tests.
- Known limitations.
- Any rule exceptions used and why.

Do not write:

```text
It should work.
Probably fixed.
Tests should pass.
```

Write exact results.

---

## 21. Forbidden Agent Behavior

AI agents must not:

- Invent successful build or test results.
- Create legacy headers for new code without explicit user request or external requirement.
- Replace modules with classic includes.
- Convert modern code to older C++ style.
- Add global mutable state casually.
- Add broad formatting noise.
- Change public API names without need.
- Modify unrelated subsystems.
- Ignore compiler warnings introduced by the change.
- Add comments in non-English languages inside code.
- Use low-level unsafe patterns without isolating them and explaining why.
