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
| `Cannot assign to non-existent property` or `Type ... unavailable` | The property belongs to another QML type, a newer Qt version, or a missing import | Exact instantiated type, inherited-member list, minimum Qt version, and strict `qmllint` output | Use an API supported by the exact type/version, preserve the intended behavior, and rerun lint plus component creation |
| `The current style does not support customization of this control` | A native/default Controls style is active while QML replaces `background`, `contentItem`, `indicator`, a delegate, or a popup | Effective style, composition-root ordering, and the named control property | Select a customizable style before QML loads and use it everywhere, or remove unsupported delegate replacement for a deliberately native design |
| `Binding loop detected for property implicitWidth/implicitHeight` | Parent viewport sizing depends on a child whose implicit size depends back on the parent's available size | Binding dependency chain and explicit/implicit size ownership | Give viewport and content a one-way geometry contract; never suppress the warning |
| Qt reports a missing font family or spends time substituting aliases | An unbundled family name or generic alias was assumed to exist cross-platform | Effective family, bundled assets/licenses, and supported-platform runs | Use Qt/system-resolved fonts or bundle and register a licensed font with an explicit fallback |
| Popup text or a primary action label is clipped/elided | Fixed control width or delegate width arithmetic was not tested with realistic content | Longest reference/translated labels, popup geometry, RTL/bilingual state, and screenshots | Size from content, allocate delegate columns explicitly, reflow actions, and keep overlays inside safe bounds |

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

## A Window That Opens Can Still Fail Verification

A linked executable may create its root window while producing unsupported
style warnings, binding loops, font substitutions, or defects only when a popup
or dialog opens. Treat those diagnostics as causal project failures. Run strict
QML lint, select the intended Controls style explicitly, make runtime warnings
fatal in the smoke environment, and exercise lazy primary-path components. A
timer that exits shortly after startup can miss the exact controls that fail.
