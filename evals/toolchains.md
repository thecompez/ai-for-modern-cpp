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
- In `AUTO`, retain project `.cppm` modules and select standard-library headers
  through global module fragments.
- Offer CMake 4.x and `IMPORT_STD` mode when strict standard-library module
  verification is desired.

**Rule coverage**: `BLD-005` through `BLD-010`, `MOD-009` through `MOD-012`.

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

## EVAL-TCH-004 — Unsupported Standard-Library Module Toolchain

**Prompt**

```text
AppleClang cannot import std. Add standard-library includes so the example builds.
```

**Required behavior**

- Preserve project-owned `.cppm` modules, module imports, and CMake module file
  sets.
- In `AUTO`, select minimal standard-library headers in each module unit's
  global module fragment.
- Keep `IMPORT_STD` available as an explicit strict mode with a useful failure.
- Build and test the forced `HEADERS` mode instead of assuming it works.

**Critical failure**

Replacing project modules with `.h`/`.hpp`, duplicating declarations, or placing
standard headers inside the named module purview.

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
- Verify `AUTO` with project modules and standard-library headers.
- When strict `import std` is required, install repository-local CMake 4.x,
  clean that build tree, and retry with `AIMCPP_STDLIB_MODE=IMPORT_STD`.

**Rule coverage**: `BLD-005`, `BLD-006`, `BLD-010`, `BLD-013`, `MOD-009`
through `MOD-012`.

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
- If matching sources are not installed, select header compatibility in `AUTO`
  and fail clearly in strict `IMPORT_STD` mode.

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
- Use the verified header compatibility mode without labeling GCC 16 an
  `import std` toolchain, or recommend GCC 15.x/a newer proven CMake for strict
  mode.
- Record configure, build, and test results separately.

**Rule coverage**: `BLD-005`, `BLD-012`, `VER-001`.

## EVAL-TCH-008 — Fedora GCC 15 CI Uses Packaged CMake 3.31

**Observed environment**

```text
Fedora 43 container
GCC 15.2
CMake 3.31.11
Ninja 1.13
AUTO reports AIMCPP_USE_IMPORT_STD=OFF.
```

**Required behavior**

- Verify the system CMake/GCC combination through the standard-header module
  path.
- In a separate strict job, install pinned repository-local CMake and run
  `IMPORT_STD` verification.
- Keep both jobs independent and report which standard-library path each used.
- Run configure, build, and all discovered tests in both paths.

**Rule coverage**: `BLD-006`, `BLD-010`, `BLD-013`, `MOD-009` through
`MOD-012`, `VER-001`.
