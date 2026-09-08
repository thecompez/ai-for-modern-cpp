# Design Qt Quick UI

Always read `AGENTS.md`, `docs/agent/EXECUTION_DISCIPLINE.md`,
`docs/agent/QT_QUICK_UI.md`, and `docs/agent/TESTING_AND_VERIFICATION.md`.
Read `START_PROJECT.md`, `PROJECT_CMAKE_BASELINE.md`, `ARCHITECTURE.md`,
`NAMING.md`, `SYNTAX_AND_STYLE.md`, `API_DESIGN.md`,
`ERRORS_AND_RESOURCES.md`, or `APP_ICONS_AND_BRANDING.md` only when the actual
UI task touches those concerns.

Inspect the current diff and owning screen/component before broader discovery.
Work as one agent by default. A local QML visual/interaction fix is normally
`V1`; presentation/domain C++ behavior is normally `V2`; QML registration,
resource/CMake topology, public adapter boundaries, or cross-surface structural
changes are `V3`; final/release verification is `V4`.

Define only the audience/flow/states, product-specific visual direction, layout
contract, accessibility/localization, and C++/QML ownership decisions needed by
the requested scope. Do not redesign unrelated screens or load every guide.
Use Qt 6, Qt Quick, QML, Qt Quick Controls, `qt_add_qml_module`, modern C++
modules, and the repository's `ui/` boundary. Preserve guarded QTP0004,
target-local nested `QML_ELEMENT` includes, non-`final` QML-creatable QObjects,
deterministic `QT_RESOURCE_ALIAS`, configured `QT_QML_OUTPUT_DIRECTORY`,
target-local `RUNTIME_OUTPUT_DIRECTORY`, and the approved Controls style where
those contracts are touched. Never edit generated `*_qmltyperegistrations.cpp`.

Implement the smallest coherent UI change. For `V1`, build the affected Qt
target when applicable, run relevant strict `qmllint`, focused warning-fatal
interaction smoke, and targeted rendered visual inspection. For `V2`, compile
the affected production C++/Qt target and relevant tests. For `V3`, reconfigure
when topology changes and cover every affected surface. For `V4`, use a clean
full default build, all tests, strict lint, primary interaction, and the
minimum/standard/wide visual acceptance matrix; record linked runtime plus
`qmldir` and `.qmltypes` paths for generated Qt projects.

Reuse compatible build state for `V1`/`V2`; after a failure, rerun from the
earliest invalidated stage. Report exact evidence and `NOT VERIFIED` layers,
then stop.

Critical Qt invariants when those surfaces are touched: run
`aimcpp_reject_final_qml_creatable_types`; a QML-creatable QObject must not be `final`; reject binding loops and a timer-only smoke flow; for a final polished
claim inspect minimum, standard, and wide states and record accidental dead space
as a visual defect when present.
