# Toolchain And Build Scenarios

## EVAL-TCH-001 — GCC 15 With Old CMake

**Prompt evidence**

```text
GCC 15.2
Ninja 1.12
CMake 3.31.6
libstdc++.modules.json exists
CMAKE_CXX_COMPILER_IMPORT_STD=''
```

**Required behavior**

- Diagnose the compatibility unit, not GCC alone.
- Identify that file existence is insufficient.
- Verify whether the active CMake release implements GCC `import std`.
- Recommend a supported CMake/toolchain path.
- Keep mandatory `import std`; do not add includes.

**Rule coverage**: `BLD-005` through `BLD-009`, `MOD-010`.

## EVAL-TCH-002 — Metadata Basename

**Prompt evidence**

```text
CMAKE_CXX_STDLIB_MODULES_JSON=libc++.modules.json
Failed to load metadata: file not found
Compiler=/opt/homebrew/Cellar/llvm/22.1.8/bin/clang++
```

**Required behavior**

- Resolve the active compiler and Homebrew LLVM prefix canonically.
- Select the matching absolute metadata path.
- Handle stale CMake compiler cache that reloads the invalid basename.
- Reconfigure, build, and test using the user's actual kit.

**Forbidden behavior**

- Selecting the first metadata file found anywhere on the machine.
- Telling the user to delete all build state before testing a safe cache repair.

## EVAL-TCH-003 — Configure Failure Cascade

**Prompt evidence**

```text
CMake fatal error: import std unsupported
ninja: build.ninja missing
CTest: no tests found
```

**Required behavior**

- Identify configure as the root failure.
- Explain why generation, build, and tests did not occur.
- Provide commands joined so later steps run only after success.

**Rule coverage**: `VER-001`, `VER-002`, `TST-006`.

## EVAL-TCH-004 — Unsupported Toolchain Downgrade Request

**Prompt**

```text
AppleClang cannot import std. Add standard-library includes so the example builds.
```

**Required behavior**

- Preserve the repository's executable proof and mandatory `import std` rule.
- Reject the unsupported toolchain at configure time.
- Offer a supported Clang/libc++ toolchain rather than changing architecture.

**Critical failure**

Any include fallback or conditional source path that stops proving `MOD-009`.
