# Design Qt Quick UI

Read `AGENTS.md` and then completely read:

- `docs/agent/START_PROJECT.md` when creating a new product or project
- `docs/agent/QT_QUICK_UI.md`
- `docs/agent/PROJECT_CMAKE_BASELINE.md`
- `docs/agent/ARCHITECTURE.md`
- `docs/agent/NAMING.md`
- `docs/agent/SYNTAX_AND_STYLE.md`
- `docs/agent/API_DESIGN.md`
- `docs/agent/ERRORS_AND_RESOURCES.md`
- `docs/agent/TESTING_AND_VERIFICATION.md`

For a new product, if the human-approved project name is missing, ask for it
and stop before writing code or selecting identifiers. Then inspect the
existing UI, CMake targets, tests, and current diff. Before editing, classify
the product surface: preserve explicit CLI, service, library, daemon,
and headless scopes, but use Qt Quick as the primary interface for an
unspecified user-facing interactive application under `GUI-015`. Then
define the audience, user flows, all screen states, product-specific visual
direction, information hierarchy, content density, affordances, feedback,
error prevention and recovery, reusable components, design tokens, and a layout
contract covering bounds, columns, gutters, shared alignment lines, spacing
scale, repeated metrics, safe insets, and grow/shrink behavior. Define compact,
standard, and wide compositions, keyboard/focus behavior, accessibility,
localization, and the QML/C++ ownership boundary. Reject generic repetitive
screen recipes.

Use Qt 6, Qt Quick, QML, Qt Quick Controls, and `qt_add_qml_module`. Keep domain
and application behavior in modern C++ modules. Keep new QML, tokens, and
visual assets under the top-level `ui/` boundary. For QML subdirectories, set
QTP0004 `NEW` behind `QT_KNOWN_POLICY_QTP0004` before module registration, and
treat missing generated `.qmltypes` after failed CMake generation as a
cascading symptom. Add directories containing nested `QML_ELEMENT` adapter
headers as target-local private include directories, and never edit generated
`*_qmltyperegistrations.cpp` files. Copy the baseline
`cmake/AimcppProjectChecks.cmake` into generated projects and run
`aimcpp_reject_final_qml_creatable_types` over every project-owned QML
registration header. A QML-creatable `QML_ELEMENT` QObject must not be `final`,
because Qt's generated registration wrapper derives from it. Do not introduce
Qt Widgets without an explicit user request or inspected compatibility
requirement.
For a generated project, begin with `PROJECT_CMAKE_BASELINE.md` instead of
assembling the CMake file from partial snippets.
Keep any secondary CLI thin, connected to the shared application/domain modules,
and subordinate to the primary interface.

Choose the Qt Quick Controls style strategy before implementing custom
controls. If the UI replaces `background`, `contentItem`, `indicator`, delegates,
or popups, select a customizable style before QML loads and keep that style
identical across application runs, lint, tests, screenshots, and packaging.
Verify every QML API on the exact instantiated type and declared minimum Qt
version. Give viewport/content and implicit-size relationships one-way geometry
ownership. Reject binding loops, missing-font substitutions, clipped popup or
bilingual/RTL rows, and fixed primary-action widths that truncate labels.

Implement the smallest coherent UI change and add C++ and QML coverage. Run
strict `qmllint` with zero project warnings and a warning-fatal interaction
smoke flow that reaches explicit readiness and instantiates primary-path lazy
popups, dialogs, delegates, editors, and responsive branches; a timer-only
launch is insufficient. In a clean tree with GUI and tests enabled, build the
full default target, run all tests, inspect the final diff, and report a
per-surface verification matrix and visual acceptance matrix. Capture and
inspect minimum, standard, and wide
screenshots across relevant appearance/content states; audit alignment,
baselines, repeated metrics, spacing, clipping, overlap, optical centering,
contrast, safe insets, and accidental dead space. An unbuilt or visually
unreviewed Qt target blocks a final archive. Report the minimum Qt version,
effective Controls style, strict lint warning count, runtime warning count, and
the lazy components exercised by the smoke flow.
