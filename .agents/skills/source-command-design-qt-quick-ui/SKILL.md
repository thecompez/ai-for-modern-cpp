---
name: "source-command-design-qt-quick-ui"
description: "Design and implement Qt Quick UI with bounded context and adaptive verification."
---

# source-command-design-qt-quick-ui

Use this skill for new Qt interfaces, QML screens, visual redesigns, Qt UI
architecture changes, and unspecified user-facing interactive applications
whose primary surface is selected by `GUI-015`.

## Required Reading

Always read:

1. `AGENTS.md`
2. `docs/agent/EXECUTION_DISCIPLINE.md`
3. `docs/agent/QT_QUICK_UI.md`
4. `docs/agent/TESTING_AND_VERIFICATION.md`

Read additional guides only when the task touches them:

- `START_PROJECT.md` for a new product/project;
- `PROJECT_CMAKE_BASELINE.md` for a generated project or QML/CMake topology;
- `ARCHITECTURE.md` when ownership/dependency boundaries change;
- `NAMING.md` when public/module identifiers change;
- `SYNTAX_AND_STYLE.md` for substantial C++ changes;
- `API_DESIGN.md` for public C++/presentation contracts;
- `ERRORS_AND_RESOURCES.md` for ownership/failure/lifetime changes;
- `APP_ICONS_AND_BRANDING.md` when application icons or in-application brand
  marks are in scope.

Do not load all guides merely because the task is graphical.

## Design And Implementation Process

1. For a new product, enforce `INI-001` through `INI-004`. If the project name
   is missing, ask and stop before writing code or choosing identifiers.
2. Inspect the current diff, owning screen/component, relevant Qt version, QML
   module/target, presentation boundary, and directly relevant tests.
3. Classify the change before broad design work:
   - a local existing-screen visual/interaction fix is normally `V1`;
   - C++ presentation/domain behavior is normally `V2`;
   - QML registration, resource topology, CMake, public adapter/API, or major
     cross-surface architecture is `V3`;
   - a final product/release claim is `V4`.
4. Work as one agent by default. Do not launch separate UI/startup/routing/test
   reviewers for one scoped screen change.
5. Define only the UX information needed by the requested scope: audience,
   primary goal, hierarchy, states, feedback/recovery, layout contract,
   accessibility/localization, and visual direction. Do not redesign unrelated
   screens.
6. Keep domain/application behavior in C++ modules and expose a minimal typed
   presentation contract to QML. Keep new QML/tokens/assets under `ui/`.
7. Use Qt Quick, QML, Qt Quick Controls, and `qt_add_qml_module`; preserve
   project module architecture and target-local presentation integration.
8. When QML subdirectories/topology are touched, preserve guarded QTP0004,
   deterministic `QT_RESOURCE_ALIAS`, module-root `Main`, configured
   `QT_QML_OUTPUT_DIRECTORY`, target-local `RUNTIME_OUTPUT_DIRECTORY`, and
   valid target-local includes for nested `QML_ELEMENT` adapters. Never edit
   generated `*_qmltyperegistrations.cpp` files. A QML-creatable QObject must
   not be `final`.
9. Choose one effective customizable Controls style when custom control surfaces
   require it, and keep that style consistent across app/lint/tests/smoke.
10. Verify QML APIs on the exact type/minimum Qt version; preserve acyclic
    geometry, content-safe actions/popups, portable fonts, focus/accessibility,
    and responsive behavior.
11. Make the smallest coherent UI change.
12. Verify according to the selected level:
    - `V1`: affected Qt target when applicable, relevant strict `qmllint`,
      focused interaction smoke, and targeted rendered visual inspection;
    - `V2`: affected production C++/Qt target + directly relevant tests and UI
      smoke;
    - `V3`: configure if topology changed + all affected product surfaces +
      relevant integration/lint/smoke;
    - `V4`: clean tree, full default target, all tests, strict lint,
      warning-fatal primary interaction, minimum/standard/wide visual acceptance
      matrix, and generated output verification.
13. Reuse compatible build state for `V1`/`V2`. After a failure, rerun from the
    earliest stage invalidated by the fix rather than restarting the full gate.
14. Report exact evidence. For final generated Qt `V4`, include the linked
    runtime target, generated `qmldir`, and `.qmltypes` paths. Any required
    unavailable surface is `NOT VERIFIED`.
15. Stop when the requested UI change and required verification are complete.

Critical Qt invariants when those surfaces are touched: run
`aimcpp_reject_final_qml_creatable_types`; a QML-creatable QObject must not be `final`; reject binding loops and a timer-only smoke flow; for a final polished
claim inspect minimum, standard, and wide states and record accidental dead space
as a visual defect when present.

## Output

Before implementation, state only the design decisions needed to execute the
requested scope and the planned verification level.

After implementation, report the standard `REP-*` evidence. When Qt lint/smoke
ran, include the minimum Qt version, effective Controls style, warning counts,
and lazy components exercised. Include a visual acceptance matrix only to the
depth required by the selected level and claimed UI quality.
