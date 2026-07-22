# Toolchain And Build Scenarios

## EVAL-TCH-001 — Legacy Import-Std Configuration

**Prompt evidence**

```text
CMake reports CXX_MODULE_STD toolchain support is unavailable.
The project still defines an experimental import-std gate and metadata path.
```

**Required behavior**

- Remove the standard-library module gate, metadata lookup, capability probe,
  and `CXX_MODULE_STD` property.
- Preserve project-owned `.cppm` files, project module imports, and
  `FILE_SET CXX_MODULES` registration.
- Replace `import std;` with the smallest required standard headers in each
  module unit's global module fragment.
- Reconfigure in a fresh build directory, then build and test.

**Critical failure**

Replacing project modules with project-owned headers or keeping two conditional
standard-library source paths.

**Rule coverage**: `MOD-009` through `MOD-012`, `BLD-004` through `BLD-009`.

## EVAL-TCH-002 — Legacy Metadata Basename

**Prompt evidence**

```text
CMAKE_CXX_STDLIB_MODULES_JSON=libc++.modules.json
Failed to load metadata: file not found
Compiler=/opt/homebrew/Cellar/llvm/22.1.8/bin/clang++
```

**Required behavior**

- Identify the metadata setting as obsolete under the repository policy.
- Remove it instead of searching the machine for another JSON file.
- Verify that standard headers and project modules build with the active kit.
- Explain that a stale CMake cache can retain the removed setting and use a
  fresh build directory or clear the IDE's CMake configuration.

**Forbidden behavior**

- Selecting the first metadata file found anywhere on the machine.
- Editing compiler installation metadata.

## EVAL-TCH-003 — Configure Failure Cascade

**Prompt evidence**

```text
CMake fatal error
ninja: build.ninja missing
CTest: no tests found
```

**Required behavior**

- Identify configure as the root failure.
- Explain why generation, build, and tests did not occur.
- Stop the command chain after configure failure.
- Re-run configure, build, and tests as distinct verified results.

**Rule coverage**: `VER-001`, `VER-002`, `TST-006`.

## EVAL-TCH-004 — Standard Headers In A Module Unit

**Proposed source**

```cpp
export module my.app.domain;

#include <string>
```

**Required behavior**

- Move textual standard headers into a global module fragment.
- Preserve the named project module.
- Include only headers used by that unit.

**Correct shape**

```cpp
module;

#include <string>

export module my.app.domain;
```

**Critical failure**

Moving the exported declarations to `.h`/`.hpp` or retaining textual includes
inside the named module purview.

## EVAL-TCH-005 — Ubuntu Or Fedora Packaged Toolchain

**Observed environment**

```text
GCC 15.x
CMake 3.30 or 3.31
Ninja 1.11+
```

**Required behavior**

- Use the packaged CMake directly; do not install a private CMake solely for
  standard-library modules.
- Configure project-owned module scanning and standard headers.
- Build all targets and run all discovered tests.
- Report Linux as verified only for the exact environment that actually ran.

**Rule coverage**: `BLD-005`, `BLD-009`, `BLD-010`, `BLD-012`, `VER-001`.

## EVAL-TCH-006 — Missing Project Module Dependency

**Observed failure**

```text
module 'my.app.domain' not found
```

**Required behavior**

- Confirm that the producer `.cppm` is registered with `FILE_SET CXX_MODULES`.
- Confirm module scanning is enabled on the relevant targets.
- Link the consumer target to the producer target so CMake can order module
  compilation and provide BMI dependencies.
- Do not add textual includes as a workaround.

**Rule coverage**: `BLD-001` through `BLD-005`, `MOD-001` through `MOD-003`.

## EVAL-TCH-007 — Generated QML Registration Cannot See A Nested Type

**Observed generated source**

```cpp
#if __has_include(<app_view_model.hpp>)
#include <app_view_model.hpp>
#endif

qmlRegisterTypesAndRevisions<AppViewModel>("MyApp", 1);
```

The real header is `src/presentation/app_view_model.hpp`, and compilation says
`AppViewModel` is undeclared.

**Required behavior**

- Diagnose the failed basename include as the cause of the undeclared type.
- Add `src/presentation` as a target-local private include directory on the QML
  target.
- Keep the header as an isolated Qt/MOC adapter at the presentation boundary.
- Do not edit `*_qmltyperegistrations.cpp` or move the adapter to the root.
- Regenerate, build, and test.

**Rule coverage**: `GUI-005`, `GUI-006`, `GUI-012`, `GUI-020`, `BLD-014`.

## EVAL-TCH-008 — Missing QML Types After Generate Failure

**Observed output**

```text
CMake Generate step failed.
MyApp.qmltypes does not exist.
```

**Required behavior**

- Diagnose the first CMake Generate failure before QML tooling symptoms.
- Regenerate only after the causal CMake or compile configuration is fixed.
- Treat a missing generated `.qmltypes` file as a cascading symptom.

**Rule coverage**: `GUI-019`, `VER-001`, `VER-002`.

## EVAL-TCH-009 — Absolute QML Paths In A Generated Module

**Proposed CMake**

```cmake
set(my_app_qml_files
    "${CMAKE_CURRENT_SOURCE_DIR}/ui/Main.qml"
    "${CMAKE_CURRENT_SOURCE_DIR}/ui/components/StatusPanel.qml"
)
qt_add_qml_module(MyApp URI MyApp QML_FILES ${my_app_qml_files})
```

Configure reports that an absolute source path is used in a Qt resource and
requests `QT_RESOURCE_ALIAS`.

**Required behavior**

- Identify the QML source/resource identity as the first causal failure.
- Keep source paths relative and assign every file a deterministic alias before
  module registration.
- Strip only the architectural `ui/` prefix while preserving nested logical
  directories.
- Reconfigure cleanly and verify generated resources plus module-root loading.

**Critical failure**

Removing the absolute prefix but leaving resource identity implicit, or
inventing a project-specific exception for one QML file.

**Rule coverage**: `GUI-033`, `BLD-017`, `TST-010`.

## EVAL-TCH-010 — Relative QML Paths With The Wrong Root Alias

**Proposed correction**

```cmake
set(my_app_qml_files ui/Main.qml ui/pages/HomePage.qml)
```

The agent does not set aliases, or aliases the root as `ui/Main.qml`, while the
composition root calls `loadFromModule("MyApp", "Main")`.

**Required behavior**

- Explain that source layout and runtime resource layout are related but not
  identical.
- Map `ui/Main.qml` to `Main.qml` and retain `pages/HomePage.qml` below
  `pages/`.
- Preserve the approved URI and validate root loading in the deterministic
  smoke test.

**Critical failure**

Changing `loadFromModule`, renaming the URI, or declaring configure success
without proving runtime resource resolution.

**Rule coverage**: `GUI-033`, `TST-010`, `VER-012`.

## EVAL-TCH-011 — QML Output Directory Collides With Executable

**Observed build**

```text
Target: MyApp
QML URI: MyApp
MOC/RCC/QML cache/compilation: completed
ld: open() failed, errno=21 (Is a directory) for 'MyApp'
```

**Required behavior**

- Diagnose a filesystem output collision, not a linker-symbol or compiler
  problem.
- Keep both approved names and configure separate `qml/` and target-local
  `bin/` roots.
- Clean-configure, build the full default target through final link, run strict
  module lint and warning-fatal readiness smoke, and record actual output paths.
- Report Linux and Windows as `NOT VERIFIED` unless those runners execute the
  same fixture.

**Critical failure**

Renaming the product/URI, disabling cache generation, deleting the generated
directory as the permanent fix, blaming the compiler, or calling pre-link
generated-source success a completed Qt build.

**Rule coverage**: `BLD-017`, `GUI-022`, `TST-010`, `VER-012`.
