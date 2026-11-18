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

The reference executable and copy-ready Qt baseline deliberately use
standard headers without stdlib module metadata or UUID gates. CMake 4.5
makes `import std;` non-experimental **for verified supported toolchains**;
see [`IMPORT_STD_CMAKE45.md`](IMPORT_STD_CMAKE45.md).

Do not introduce automatic, strict, or fallback modes to silently change
standard-library delivery. One source path per project is easier to understand,
build, test, and reproduce.

Language mode is not a library feature guarantee. See
[`CPP20_26_FEATURES.md`](CPP20_26_FEATURES.md) and rule `FEAT-001`:
probe the actual compiler, standard-library headers, feature-test macros
and linked runtime before selecting optional C++23/26 APIs. CMake 4.5's
non-experimental `import std;` support does not manufacture missing library APIs.

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

## CMake 4.5 Opt-In: `import std;`

The old `CMAKE_EXPERIMENTAL_CXX_IMPORT_STD` UUID and
`CMAKE_CXX_COMPILER_IMPORT_STD` / `CMAKE_CXX_MODULE_STD` /
target `CXX_MODULE_STD` mechanisms are not used on CMake 4.5.
The compiler/stdlib must have discoverable module metadata and the target
must enable `CXX_SCAN_FOR_MODULES` with Ninja. Scanning alone does not
turn ordinary header includes into imports.

`CMAKE_CXX_STDLIB_MODULES_JSON` is a **new**, optional CMake 4.5 metadata-path
override; it is not an experimental gate. Use it only with a verified installed
file if compiler discovery fails, never by guessing or repairing vendor files.

Consult [`IMPORT_STD_CMAKE45.md`](IMPORT_STD_CMAKE45.md) for the official
toolchain matrix, Ubuntu caveat, a working-shaped standalone probe, and
required clean build and tests. Do not alter the portable baseline without
explicit approval.

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
  the QML target with `target_include_directories`;
- copy `cmake/AimcppProjectChecks.cmake` and run
  `aimcpp_reject_final_qml_creatable_types` on every project-owned QML
  registration header before QML module registration;
- when controls replace visual delegates, define one customizable Qt Quick
  Controls style and select it in the composition root before QML loads;
- use the same minimum Qt version and effective Controls style for the
  application, strict QML lint, interaction tests, screenshots, and packaging;
- provide a strict `qmllint` target with zero project warnings and a
  warning-fatal runtime interaction test.
- list QML files with source-relative paths and assign deterministic
  `QT_RESOURCE_ALIAS` values before module registration, removing the
  architectural `ui/` prefix while retaining logical subdirectories;
- configure a project-wide `QT_QML_OUTPUT_DIRECTORY` for module artifacts and a
  target-local `RUNTIME_OUTPUT_DIRECTORY` for each executable so a target and
  URI with the same approved name cannot collide;
- make strict lint import the configured QML output root and use only command
  options supported by the declared minimum Qt version.

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

The final verification configuration must leave every requested product option
enabled and build the default `all` target. Building only a core library or test
target does not exercise Qt-generated MOC, registration, resource, and QML cache
sources and cannot validate the graphical application.

### QML Resource Identity And Output Identity

Source layout, resource layout, and generated output layout are related but
serve different responsibilities:

```text
ui/Main.qml                              source boundary
:/qt/qml/MyApp/Main.qml                 resource identity
<build>/qml/MyApp/qmldir                generated module metadata
<build>/bin/MyApp[.exe]                 runtime target
```

Set `QT_RESOURCE_ALIAS` before `qt_add_qml_module`; removing an absolute path
alone does not define the desired resource identity. The root alias must agree
with `loadFromModule`, and aliases for nested files must preserve their logical
module directories.

Qt derives a default QML output directory from the URI. For an executable
backing target, a URI root equal to the target name can otherwise create a
directory at the exact path where a non-bundle executable must be linked.
Separate `qml/` and `bin/` roots instead of changing the approved target or URI.
The linker reaching this collision after MOC, RCC, cache generation, and C++
compilation is still a failed full build.

For the declared Qt 6.6 minimum, `qmllint` supports `--bare`, `-I`, and module
mode (`-M`). `--max-warnings` is available only from Qt 6.8, so generated CMake
must add it conditionally while retaining the zero-warning gate on Qt 6.6/6.7.

The copy-ready implementation is in `PROJECT_CMAKE_BASELINE.md`. Its style
compile definition, `QQuickStyle::setStyle` ordering, strict lint target, and
warning-fatal smoke environment form one contract. Do not remove one piece and
fall back to the workstation's native style. The smoke executable must
understand `--smoke-test`, reach explicit readiness, and exercise primary-path
lazy QML; a fixed timer is not sufficient evidence.

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

When migrating legacy experimental import-std configurations:

1. Remove the UUID gate and the obsolete pre-4.5 import-std capability and
   `CXX_MODULE_STD` toggles.
2. For the default portable baseline, restore minimal standard headers in
   global module fragments and keep application-owned `.cppm` modules.
3. Only for a separately approved CMake 4.5+ import-std project, keep
   `import std;` after verifying the compiler, stdlib, Ninja, clean build,
   and tests. Treat the new metadata-path override as optional.
4. Recreate the build directory to eliminate stale experimental cache state.

Do not incorrectly remove a valid CMake 4.5 metadata override from a
verified import-std project.

## Linux

GCC 15, CMake 3.30/3.31, and Ninja can build project-owned modules with standard
headers. No repository-local CMake bootstrap or libstdc++ module metadata repair
is required. Fedora and Ubuntu verification should use their packaged CMake and
the same `scripts/verify-linux.sh` path.

Do not infer support from version numbers alone. Each compiler/CMake/generator
combination must still pass configure, build, and tests.
