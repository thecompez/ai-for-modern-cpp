# CMake And Toolchain Decisions

Use this guide for build-system edits, compiler selection, C++ modules, and
standard-library integration failures. Canonical rules: `BLD-*` and
`MOD-009` through `MOD-012`.

## Compatibility Unit

Never diagnose the compiler in isolation.

```text
Compiler
  + Standard library
  + Standard-library module metadata
  + CMake experimental gate and implementation
  + Ninja module dependency support
  + Selected language standard
= Effective import std capability
```

`CMAKE_CXX_COMPILER_IMPORT_STD` is the configure-time evidence. A version
number alone is not proof.

## Standard-Library Integration Modes

Project-owned C++ modules are mandatory in every mode. Standard-library
delivery is selected independently:

| `AIMCPP_STDLIB_MODE` | Behavior |
|---|---|
| `AUTO` | Prefer `import std`; use standard headers when capability or metadata is unavailable |
| `IMPORT_STD` | Require the experimental standard-library module path and fail clearly if unavailable |
| `HEADERS` | Force standard headers for compatibility-path verification |

When `import std` is selected, configure:

```cmake
set(CMAKE_CXX_MODULE_STD ON)
set(CMAKE_CXX_SCAN_FOR_MODULES ON)
```

When header compatibility is selected, keep module scanning enabled for
project modules, set `CXX_MODULE_STD` to `OFF`, and provide one target-wide
compile definition that selects global-module-fragment standard headers.

The source architecture remains:

```cpp
module;

#if !APP_USE_IMPORT_STD
#include <print>
#include <string>
#endif

export module project.output;

#if APP_USE_IMPORT_STD
import std;
#endif
```

Do not create a classic header/source implementation or a second source tree.
The only fallback is how standard-library declarations enter otherwise
unchanged project module units.

## Target-Based CMake

Preferred:

```cmake
target_compile_features(project_core PUBLIC cxx_std_26)
target_compile_options(project_core PRIVATE -Wall -Wextra)
target_sources(project_core
    PUBLIC
        FILE_SET CXX_MODULES
        FILES src/project/project.cppm
    PRIVATE
        src/project/project.cpp
)
```

Avoid global `CMAKE_CXX_FLAGS`, directory-wide include paths, or broad compile
definitions unless they are truly toolchain-wide and documented.

For Qt Quick targets, use `find_package` with only the required Qt components,
register QML through `qt_add_qml_module`, and link target-local `Qt6::Quick`,
`Qt6::Qml`, and Qt Quick Controls dependencies. Do not introduce `Qt6::Widgets`
for a new UI without the explicit exception required by `GUI-002`. See
`QT_QUICK_UI.md`.

## Configure Failure Workflow

Collect evidence before editing:

```bash
cmake --version
ninja --version
c++ --version
c++ -print-file-name=libstdc++.modules.json
```

Then inspect:

```text
CMAKE_VERSION
CMAKE_GENERATOR
CMAKE_CXX_COMPILER_ID
CMAKE_CXX_COMPILER_VERSION
CMAKE_CXX_COMPILER_IMPORT_STD
CMAKE_CXX_STDLIB_MODULES_JSON
```

Also inspect:

```text
AIMCPP_STDLIB_MODE
AIMCPP_USE_IMPORT_STD
```

In `AUTO`, an empty import capability is a selection result rather than a
configure failure. If configure does fail, stop. Do not run build and tests and
then report missing `build.ninja` or zero tests as additional root causes.

## Experimental Gates

Experimental UUIDs are CMake-version-specific capability gates. Keep them
scoped to documented version ranges. Do not guess a UUID or reuse an older
value silently. An unknown gate selects `HEADERS` behavior in `AUTO` and is a
configuration error only in explicit `IMPORT_STD` mode.

## macOS Homebrew LLVM

Homebrew may expose LLVM through both `opt/llvm` and a versioned `Cellar` path.
Resolve canonical paths before associating `libc++.modules.json` with the active
compiler. Never select metadata merely because a matching file exists somewhere
on the machine.

## Linux GCC

GCC 15 support also requires a CMake release that implements GCC `import std`
and a valid `libstdc++.modules.json`. A file's existence does not prove that its
source paths or package integration are correct.

Verified GNU `import std` baseline:

```text
GCC 15.x
CMake 4.0+
Ninja 1.11+
matching libstdc++ development package
```

CMake 3.30 and 3.31 do not implement GCC/libstdc++ `import std`. `AUTO` keeps
project `.cppm` modules and selects standard-library headers; `IMPORT_STD`
rejects the combination. A JSON file's existence does not change that result.

Some Linux packages install a `libstdc++.modules.json` whose relative
`source-path` entries do not resolve. `cmake/AimcppImportStd.cmake` validates
each entry before `project()` and writes corrected absolute paths to generated
metadata in the build tree. It never edits `/usr` or the compiler installation.

Do not infer `import std` support for a new GCC major from version ordering. For
example, GCC 16.1 with CMake 4.3.4 advertises import capability during configure
but the CMake scanner does not recognize its standard module during the build.
`AUTO` may select the verified header path; do not label the compiler an
`import std` toolchain until its full strict build passes.

### Ubuntu 25.10

Ubuntu 25.10 provides GCC 15 and CMake 3.31. The default `AUTO` mode can build
project modules with standard-library headers. To verify the preferred
`import std` path, use the repository-local bootstrap and strict mode:

```bash
bash scripts/bootstrap-linux-cmake.sh
.tools/cmake/bin/cmake -E remove_directory build/linux-gcc-debug
AIMCPP_STDLIB_MODE=IMPORT_STD bash scripts/verify-linux.sh
```

The bootstrap installs pinned CMake 4.3.4 into the ignored `.tools/` directory;
it does not replace the system CMake.

### Fedora 43

Fedora 43 provides GCC 15.2 and CMake 3.31. Its system toolchain should verify
the `AUTO` header path. For strict `import std`, install the Python tooling, run
the repository-local CMake 4.3.4 bootstrap, and verify the full path:

```bash
sudo dnf install --assumeyes gcc-c++ ninja-build python3 python3-pip
bash scripts/bootstrap-linux-cmake.sh
.tools/cmake/bin/cmake -E remove_directory build/linux-gcc-debug
AIMCPP_STDLIB_MODE=IMPORT_STD bash scripts/verify-linux.sh
```
