# CMake And Toolchain Decisions

Use this guide for build-system edits, compiler selection, C++ modules, and
standard-library integration failures. Canonical rules: `BLD-*` and `MOD-009`
through `MOD-012`.

For a combined generated-project shape, use
[`PROJECT_CMAKE_BASELINE.md`](PROJECT_CMAKE_BASELINE.md).

## Supported Architecture

```text
Compiler with project-module support
  + CMake 3.30+
  + Ninja 1.11+
  + selected C++20/23/26 language level
  + standard-library headers
= deterministic project-module build
```

The repository deliberately does not use experimental standard-library
modules. It does not inspect or configure:

```text
CMAKE_EXPERIMENTAL_CXX_IMPORT_STD
CMAKE_CXX_COMPILER_IMPORT_STD
CMAKE_CXX_STDLIB_MODULES_JSON
CMAKE_CXX_MODULE_STD
libc++.modules.json
libstdc++.modules.json
```

Do not add automatic, strict, or fallback modes for standard-library delivery.
One source path is easier to understand, build, test, and reproduce.

## Standard Headers Inside Project Modules

The project module remains a module; only the standard library is textual:

```cpp
module;

#include <print>
#include <string>

export module project.output;

export namespace project::output {
void printMessage(const std::string& message);
}
```

Standard headers must appear in the global module fragment. They must not be
included after the named module declaration.

## Target-Based CMake

```cmake
add_library(project_core)

target_compile_features(project_core PUBLIC cxx_std_26)

target_sources(project_core
    PUBLIC
        FILE_SET CXX_MODULES
        FILES src/project/project.cppm
    PRIVATE
        src/project/project.cpp
)

set_property(TARGET project_core PROPERTY CXX_SCAN_FOR_MODULES ON)
```

Consumers link the owning target and use `import project.name;`. Do not add
project include directories merely to simulate classic header architecture.

Avoid global `CMAKE_CXX_FLAGS`, directory-wide include paths, or broad compile
definitions unless they are truly toolchain-wide and documented.

## Qt Quick Targets

For Qt Quick targets:

- use `find_package` with only required Qt components;
- register QML through `qt_add_qml_module`;
- guard QTP0004 before QML module registration;
- link target-local `Qt6::Quick`, `Qt6::Qml`, and Qt Quick Controls dependencies;
- add every nested directory containing a project-owned `QML_ELEMENT` header to
  the QML target with `target_include_directories`.

Qt's generated type registration source may include a MOC adapter by basename.
If `src/presentation/app_view_model.hpp` is not on the target include path, the
generated source can discover the type metadata but still fail to compile with
an undeclared class name.

```cmake
target_include_directories(MyApp
    PRIVATE
        "${CMAKE_CURRENT_SOURCE_DIR}/src/presentation"
)
```

Do not move the adapter to the repository root and do not edit generated
`*_qmltyperegistrations.cpp` files.

## Configure Failure Workflow

Collect evidence before editing:

```bash
cmake --version
ninja --version
c++ --version
```

Then inspect:

```text
CMAKE_VERSION
CMAKE_GENERATOR
CMAKE_CXX_COMPILER_ID
CMAKE_CXX_COMPILER_VERSION
CMAKE_CXX_STANDARD
CXX_SCAN_FOR_MODULES
```

If configure fails, stop. Do not run build and tests and then report missing
`build.ninja` or zero tests as additional root causes.

## Legacy Import-Std Projects

When migrating a generated project that still contains experimental import-std
configuration:

1. Remove experimental UUID gates and standard-library metadata handling.
2. Remove `CMAKE_CXX_MODULE_STD` and target `CXX_MODULE_STD` properties.
3. Remove standard-library mode options and compile definitions.
4. Replace `import std;` with minimal standard headers.
5. In module units, put those headers in the global module fragment.
6. Preserve `.cppm`, project module declarations, project imports, and
   `FILE_SET CXX_MODULES`.
7. Recreate the build directory because compiler-detection cache may still
   contain the obsolete experimental configuration.

## Linux

GCC 15, CMake 3.30/3.31, and Ninja can build project-owned modules with standard
headers. No repository-local CMake bootstrap or libstdc++ module metadata repair
is required. Fedora and Ubuntu verification should use their packaged CMake and
the same `scripts/verify-linux.sh` path.

Do not infer support from version numbers alone. Each compiler/CMake/generator
combination must still pass configure, build, and tests.
