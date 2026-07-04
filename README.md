# AI for Modern C++

A template repository for AI-assisted modern C++ development.

This repository demonstrates how to guide coding agents such as Claude Code, Codex, GitHub Copilot, and other AI development tools when working on modern C++ projects.

The preferred primary compiler path is Clang 22+ with Ninja and modern CMake. The focus is not only on writing C++ code. The focus is on making AI agents follow a strict engineering process:

- ISO C++ Core Guidelines.
- C++20 minimum.
- C++23/C++26 preferred.
- C++ modules by default.
- Declaration in `.cppm`.
- Implementation in `.cpp`.
- Optional dependency headers in `.hpp`, never `.h`.
- Concepts for compile-time constraints.
- Build and test verification before claiming success.
- No legacy C++ style for new code.
- No fake success reports.
- Repeatable AI loop testing.

## Repository Purpose

This repository is meant to be copied into new C++ repositories as an AI-agent instruction baseline.

It contains:

```text
AGENTS.md                  Canonical AI agent guide
CLAUDE.md                  Claude Code pointer
.claude/commands/          Claude slash-command examples
.github/workflows/ci.yml   Example CI workflow
CMakeLists.txt             Modern CMake + optional import std support
src/                       Example C++ module code
tests/                     Minimal test executable
docs/                      Additional engineering notes
```

## Build

```bash
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build --parallel
ctest --test-dir build --output-on-failure
```

To disable experimental `import std` integration:

```bash
cmake -S . -B build -G Ninja -DAIMCPP_ENABLE_IMPORT_STD=OFF
```

## Modern Module Layout

Declaration:

```text
src/modern_cpp_agent/modern_cpp_agent.cppm
```

Implementation:

```text
src/modern_cpp_agent/modern_cpp_agent.cpp
```

Optional dependency boundary:

```text
src/modern_cpp_agent/modern_cpp_agent.compat.hpp
```

## License

MIT


## Module Naming

```cpp
export module modern.cpp.agent;
import modern.cpp.agent;

export namespace modern::cpp::agent {
}
```

Private members use `m_` prefix.


## Safety Policy

This template discourages raw owning pointers, manual `new` / `delete`, C-style casts, C-style owned arrays, hidden global mutable state, and macro-driven business logic by default.

Those patterns are not absolutely impossible. They are allowed only when the user explicitly requests them or when low-level systems work, ABI boundaries, C interop, custom allocators, platform APIs, or compiler workarounds require them.

When used, they must be isolated behind a small RAII-safe abstraction and explained in the final agent report.


## Showcase Example

`src/main.cpp` intentionally demonstrates multiple modern C++ patterns in a compact executable:

- `import std;`
- `import modern.cpp.agent;`
- dot-separated module names.
- namespace mirroring: `modern::cpp::agent`.
- concepts-based rendering with `TextRenderable`.
- `consteval` and `static_assert`.
- `std::expected`.
- `std::optional`.
- `std::span`.
- `std::ranges` algorithms and range-aware APIs.
- `std::chrono`.
- `std::format` and `std::println`.
- designated initializers.
- clean `m_` private member style inside exported types.


## Portability Note

The showcase avoids `std::views::enumerate` because some current Clang/libc++ combinations may not ship it yet, even under `-std=gnu++26`.

For public templates, prefer modern features that are actually available in the target toolchain instead of demonstrating syntax that does not compile.
