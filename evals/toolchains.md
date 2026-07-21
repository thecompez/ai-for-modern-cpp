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

## EVAL-TCH-005 — Ubuntu GCC 15 With CMake 3.31

**Observed environment**

```text
Ubuntu 25.10
GCC 15.2
CMake 3.31.6
Ninja 1.12
libstdc++.modules.json exists
CMAKE_CXX_COMPILER_IMPORT_STD=''
```

**Required diagnosis**

- Identify CMake 3.31 as older than GNU `import std` support.
- Do not claim that manually passing the JSON can add missing CMake behavior.
- Install a repository-local CMake 4.x, clean the build tree, and retry.
- Preserve mandatory `import std`; do not create an include fallback.

**Rule coverage**: `BLD-005`, `BLD-006`, `BLD-010`, `MOD-009`.

## EVAL-TCH-006 — Broken GNU Metadata Source Path

**Observed environment**

```text
g++ -print-file-name=libstdc++.modules.json returns an existing file.
The JSON source-path for std.cc does not exist relative to that file.
```

**Required behavior**

- Validate every metadata module source, not only the JSON file.
- Locate the matching compiler-major module sources.
- Generate corrected metadata in the build tree with absolute source paths.
- Never edit system compiler files.
- Fail clearly if matching sources are not installed.

**Rule coverage**: `BLD-006`, `BLD-011`, `SEC-005`.

## EVAL-TCH-007 — Unverified New Compiler Major

**Observed output**

```text
GCC 16.1 and CMake 4.3 configure successfully.
CMake module collation says std.cc does not provide a module interface.
```

**Required behavior**

- Treat configure capability as necessary but insufficient evidence.
- Keep GCC 16 out of the supported matrix for that CMake release.
- Recommend the verified GCC 15.x path or a newer CMake proven end-to-end.
- Record configure, build, and test results separately.

**Rule coverage**: `BLD-005`, `BLD-012`, `VER-001`.

## EVAL-TCH-008 — Fedora GCC 15 CI Uses Packaged CMake 3.31

**Observed environment**

```text
Fedora 43 container
GCC 15.2
CMake 3.31.11
Ninja 1.13
Configure rejects GCC import std before project generation.
```

**Required behavior**

- Identify the CI provisioning mismatch rather than weakening `import std`.
- Install the pinned repository-local CMake before running Linux verification.
- Keep the Fedora build independent from the distribution's system CMake.
- Run configure, build, and all discovered tests with the bootstrapped CMake.

**Rule coverage**: `BLD-006`, `BLD-010`, `MOD-009`, `VER-001`.
