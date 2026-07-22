# Common Failure Catalog

Use this catalog after collecting real command output. Do not select a diagnosis
only because the symptom looks familiar.

| Symptom | Likely cause | Evidence | Correct direction |
|---|---|---|---|
| `build.ninja: No such file` | Configure failed before generation | Earlier CMake error | Fix configure; do not diagnose Ninja separately |
| `No tests were found` after configure failure | No valid test build tree exists | Missing generated test files | Fix configure/build first |
| Imported project module was not found | Producer is not registered in `FILE_SET CXX_MODULES`, consumer is not linked, or scanning is disabled | Target sources, links, and `CXX_SCAN_FOR_MODULES` | Restore target-based module registration and dependency edges |
| Module dependency cycle after source changes | Real import cycle or stale dynamic dependency state | Scanner output and module graph | Fix the graph; regenerate cleanly if scanner state is stale |
| Standard header is included after `export module` | Textual declarations entered the named module purview | Ordering around `module;` and the named declaration | Move the standard header into the global module fragment |
| Build still asks for `libc++.modules.json` or `libstdc++.modules.json` | Legacy experimental standard-library module configuration remains in CMake cache or sources | Search for import-std gates, metadata variables, and `CXX_MODULE_STD` | Remove the obsolete configuration and recreate the build directory |
| `module 'std' not found` | Legacy source still contains `import std;` | First compiler failure and source search | Replace it with minimal standard headers; preserve project modules |
| Generated QML registration reports a project type is undeclared | Qt generated a basename header include, but the nested presentation directory is not on the target include path | Inspect `*_qmltyperegistrations.cpp` and the failing compile command | Add the adapter directory with target-local `target_include_directories` |
| Qt says a QML element base is marked `final` | A `QML_ELEMENT` type is creatable from QML, but Qt's generated wrapper cannot derive from it | Generated registration stack, the adapter declaration, and baseline preflight coverage | Remove `final` from the QML-creatable QObject or choose and verify a non-creatable ownership strategy; add the header to `aimcpp_reject_final_qml_creatable_types` |
| IDE reports a generated `.qmltypes` file is missing after CMake Generate failed | QML type generation never completed | Find the first earlier CMake failure | Fix the first Generate failure, clear stale CMake state, and regenerate |
| Qt warns that QTP0004 is not set for QML files in extra directories | The project did not select the policy | Declared Qt minimum and order around QML registration | Guard `qt_policy(SET QTP0004 NEW)` before `qt_add_qml_module` |

## Generated QML Registration Diagnosis

Qt registration code commonly uses a conditional basename include:

```cpp
#if __has_include(<app_view_model.hpp>)
#include <app_view_model.hpp>
#endif
```

If compilation later says `AppViewModel` is undeclared, do not add a namespace
guess and do not edit the generated file first. Compare the include with the
compile command. When `-I.../src/presentation` is absent, add that directory to
the owning QML target and regenerate.

## Diagnosis Discipline

1. Quote the first causal error.
2. Record exact tool versions and selected paths.
3. Separate observed facts from inference.
4. Prefer the smallest read-only check that can falsify the hypothesis.
5. Preserve project-owned modules while repairing build integration.

## Escalation Evidence

When local diagnosis is insufficient, request only the outputs needed:

```bash
cat /etc/os-release
cmake --version
ninja --version
c++ --version
```

Never request tokens, unrelated environment dumps, or broad private filesystem
listings.

## Partial Success Is Not Product Success

If Qt is absent and a build succeeds only because the GUI option was disabled,
record the core and tests as `PASS` and the Qt application as `NOT VERIFIED`.
Do not call the application ready. Re-run a clean configuration with GUI and
tests enabled, build the full `all` target, run all tests, and run a GUI/QML
smoke flow before final delivery.
