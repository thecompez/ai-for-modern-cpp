# CMake And Toolchain Decisions

Use this guide for build-system edits, compiler selection, C++ modules, and
`import std` failures. Canonical rules: `BLD-*`, `MOD-009`, and `MOD-010`.

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

## Strict `import std` Policy

This executable reference always uses `import std;`. It must configure:

```cmake
set(CMAKE_CXX_MODULE_STD ON)
set(CMAKE_CXX_SCAN_FOR_MODULES ON)
```

Targets also set `CXX_MODULE_STD` and `CXX_SCAN_FOR_MODULES`. If the effective
toolchain does not advertise C++23 or C++26 support, configuration fails.

Do not add conditional standard-library includes as a fallback. Doing so would
make the executable proof stop proving the documented architecture.

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

If configure fails, stop. Do not run build and tests and then report missing
`build.ninja` or zero tests as additional root causes.

## Experimental Gates

Experimental UUIDs are CMake-version-specific capability gates. Keep them
scoped to documented version ranges and fail on unknown future ranges until
verified. Do not guess a UUID or reuse an older value silently.

## macOS Homebrew LLVM

Homebrew may expose LLVM through both `opt/llvm` and a versioned `Cellar` path.
Resolve canonical paths before associating `libc++.modules.json` with the active
compiler. Never select metadata merely because a matching file exists somewhere
on the machine.

## Linux GCC

GCC 15 support also requires a CMake release that implements GCC `import std`
and a valid `libstdc++.modules.json`. A file's existence does not prove that its
source paths or package integration are correct.

Supported GNU baseline:

```text
GCC 15.x
CMake 4.0+
Ninja 1.11+
matching libstdc++ development package
```

CMake 3.30 and 3.31 can expose `CMAKE_CXX_COMPILER_IMPORT_STD`, but those
releases do not implement GCC/libstdc++ `import std`. They must not be treated
as supported merely because GCC 15 and the JSON file exist.

Some Linux packages install a `libstdc++.modules.json` whose relative
`source-path` entries do not resolve. `cmake/AimcppImportStd.cmake` validates
each entry before `project()` and writes corrected absolute paths to generated
metadata in the build tree. It never edits `/usr` or the compiler installation.

Do not infer support for a new GCC major from version ordering. For example,
GCC 16.1 with CMake 4.3.4 advertises import capability during configure but the
CMake scanner does not recognize its standard module during the build. Keep a
new major version out of the supported matrix until the full build passes.

### Ubuntu 25.10

Ubuntu 25.10 provides GCC 15 but its CMake 3.31 is too old for GNU `import std`.
Use the repository-local bootstrap, then the Linux verification script:

```bash
bash scripts/bootstrap-linux-cmake.sh
.tools/cmake/bin/cmake -E remove_directory build/linux-gcc-debug
bash scripts/verify-linux.sh
```

The bootstrap installs pinned CMake 4.3.4 into the ignored `.tools/` directory;
it does not replace the system CMake.

### Fedora 43

Fedora 43 provides GCC 15.2 but its CMake 3.31 package is also too old for GNU
`import std`. Do not infer CMake compatibility from the distribution or compiler
version. Install the Python tooling, run the same repository-local CMake 4.3.4
bootstrap, and then verify the full configure/build/test path:

```bash
sudo dnf install --assumeyes gcc-c++ ninja-build python3 python3-pip
bash scripts/bootstrap-linux-cmake.sh
.tools/cmake/bin/cmake -E remove_directory build/linux-gcc-debug
bash scripts/verify-linux.sh
```
