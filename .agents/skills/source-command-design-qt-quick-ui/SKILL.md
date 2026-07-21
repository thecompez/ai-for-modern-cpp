---
name: "source-command-design-qt-quick-ui"
description: "Design and implement a Qt Quick interface with a deliberate visual system and a clean C++ module boundary."
---

# source-command-design-qt-quick-ui

Use this skill for new Qt interfaces, QML screens, visual redesigns, and Qt UI
architecture changes.

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

1. Inspect the existing Qt version, QML modules, CMake targets, screens,
   components, tests, and current diff.
2. Define the primary user goal, navigation, actions, and authoritative state.
3. Enumerate loading, empty, success, disabled, and failure states.
4. Define reusable components and design tokens for spacing, typography, color,
   radius, and motion.
5. Define responsive behavior, keyboard path, focus order, accessible names,
   and localization needs.
6. Draw the QML → presentation adapter → application → domain dependency path.
7. Keep domain/application behavior in C++ modules and expose only a minimal
   typed presentation contract to QML.
8. Use Qt Quick, QML, Qt Quick Controls, and `qt_add_qml_module`.
9. Do not introduce Qt Widgets unless the user explicitly requests it or an
   inspected compatibility boundary requires it; document the exception.
10. Add C++ presentation tests and relevant QML interaction, lint, or smoke
    coverage.
11. Configure, build, test with zero-tests-as-error, inspect the final diff, and
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
