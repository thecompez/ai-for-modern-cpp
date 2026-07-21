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
3. `docs/agent/ARCHITECTURE.md`
4. `docs/agent/NAMING.md`
5. `docs/agent/SYNTAX_AND_STYLE.md`
6. `docs/agent/API_DESIGN.md`
7. `docs/agent/ERRORS_AND_RESOURCES.md`
8. `docs/agent/TESTING_AND_VERIFICATION.md`

## Design Process

1. Classify the requested product surface. Preserve explicit CLI, service,
   library, daemon, and headless scopes; otherwise apply `GUI-015` to an
   unspecified user-facing interactive application.
2. Inspect the existing Qt version, QML modules, CMake targets, screens,
   components, tests, and current diff.
3. Define the primary user goal, navigation, actions, and authoritative state.
4. Enumerate loading, empty, success, disabled, and failure states.
5. Define reusable components and design tokens for spacing, typography, color,
   radius, and motion.
6. Define responsive behavior, keyboard path, focus order, accessible names,
   and localization needs.
7. Draw the QML → presentation adapter → application → domain dependency path,
   plus any optional CLI adapter that shares the application layer.
8. Keep domain/application behavior in C++ modules and expose only a minimal
   typed presentation contract to QML.
9. Use Qt Quick, QML, Qt Quick Controls, and `qt_add_qml_module`.
10. Do not introduce Qt Widgets unless the user explicitly requests it or an
   inspected compatibility boundary requires it; document the exception.
11. Keep any secondary CLI thin and connected to the same application/domain
    modules; do not let it replace the primary interface.
12. Add C++ presentation tests and relevant QML interaction, lint, or smoke
    coverage.
13. Configure, build, test with zero-tests-as-error, inspect the final diff, and
    report exact evidence.

## Output

Before implementation, state:

- user flow and screen-state model;
- visual/component system;
- accessibility and responsive decisions;
- C++/QML ownership boundary;
- planned verification.

After implementation, report the standard `REP-*` evidence plus any UI states
or platforms that were not visually or interactively verified.
