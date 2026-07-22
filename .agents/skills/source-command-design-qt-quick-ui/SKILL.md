---
name: "source-command-design-qt-quick-ui"
description: "Design and implement a Qt Quick interface with a deliberate visual system and a clean C++ module boundary."
---

# source-command-design-qt-quick-ui

Use this skill for new Qt interfaces, QML screens, visual redesigns, Qt UI
architecture changes, and unspecified user-facing interactive applications
whose primary surface is selected by `GUI-015`.

## Required Reading

Read completely before editing:

1. `AGENTS.md`
2. `docs/agent/QT_QUICK_UI.md`
3. `docs/agent/PROJECT_CMAKE_BASELINE.md`
4. `docs/agent/ARCHITECTURE.md`
5. `docs/agent/NAMING.md`
6. `docs/agent/SYNTAX_AND_STYLE.md`
7. `docs/agent/API_DESIGN.md`
8. `docs/agent/ERRORS_AND_RESOURCES.md`
9. `docs/agent/TESTING_AND_VERIFICATION.md`

## Design Process

1. Classify the requested product surface. Preserve explicit CLI, service,
   library, daemon, and headless scopes; otherwise apply `GUI-015` to an
   unspecified user-facing interactive application.
2. Inspect the existing Qt version, QML modules, CMake targets, screens,
   components, tests, and current diff.
3. Define the audience, usage context, primary user goal, navigation, actions,
   and authoritative state.
4. Define a product-specific visual direction, information hierarchy, and
   content density. Reject generic repeated card, gradient, glass-panel, and
   dashboard recipes that are not justified by the product task.
5. Enumerate loading, empty, success, disabled, and failure states, including
   affordances, immediate feedback, error prevention, and recovery.
6. Define reusable components and design tokens for spacing, typography, color,
   radius, and motion without making every screen composition repetitive.
7. Define a layout contract: outer bounds, maximum task width, columns, gutters,
   shared alignment lines, spacing scale, repeated-control metrics, safe insets,
   and each region's grow, shrink, wrap, or overflow behavior.
8. Define compact, standard, and wide compositions, plus keyboard path, focus
   order, accessible names, and localization needs.
9. Draw the QML → presentation adapter → application → domain dependency path,
   plus any optional CLI adapter that shares the application layer.
10. Keep domain/application behavior in C++ modules and expose only a minimal
   typed presentation contract to QML.
11. Place new QML, design tokens, and visual assets under the top-level `ui/`
    boundary, using responsibility-based subdirectories only when needed.
12. For a generated project, start from `PROJECT_CMAKE_BASELINE.md`; do not
    reconstruct module and Qt integration from partial snippets.
13. Use Qt Quick, QML, Qt Quick Controls, and `qt_add_qml_module`.
14. For QML subdirectories, select QTP0004 `NEW` behind
    `QT_KNOWN_POLICY_QTP0004` before `qt_add_qml_module`. Treat missing generated
    `.qmltypes` after a failed CMake Generate step as a cascading symptom.
15. Add every directory containing a nested `QML_ELEMENT` adapter header as a
    target-local private include directory. Never patch generated
    `*_qmltyperegistrations.cpp` files.
16. A QML-creatable `QML_ELEMENT` QObject must not be `final`; Qt's generated
    registration wrapper derives from it.
17. Do not introduce Qt Widgets unless the user explicitly requests it or an
   inspected compatibility boundary requires it; document the exception.
18. Keep any secondary CLI thin and connected to the same application/domain
    modules; do not let it replace the primary interface.
19. Add C++ presentation tests and relevant QML interaction, lint, geometry, or
    smoke coverage.
20. In a clean tree with the GUI and tests enabled, build the full default
    target, run all tests and a GUI/QML smoke flow, inspect the final diff, and
    report exact per-surface evidence. Do not deliver a final archive when the
    Qt surface is unbuilt or `NOT VERIFIED`.
21. Capture rendered screenshots at minimum, standard, and wide sizes across
    relevant appearance/content states. Audit alignment lines, repeated metrics,
    spacing rhythm, clipping, overlap, truncation, optical centering, contrast,
    safe insets, and accidental dead space before calling the UI polished.

## Output

Before implementation, state:

- audience, user flow, and screen-state model;
- product-specific visual direction, hierarchy, density, and component system;
- layout contract, breakpoint compositions, alignment anchors, and spacing
  scale;
- affordance, feedback, prevention, and recovery decisions;
- accessibility and responsive decisions;
- C++/QML ownership boundary;
- planned verification.

After implementation, report the standard `REP-*` evidence plus any UI states
or platforms that were not visually or interactively verified, and include the
viewport/appearance/content-state visual acceptance matrix.
