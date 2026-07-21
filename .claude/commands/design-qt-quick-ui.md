# Design Qt Quick UI

Read `AGENTS.md` and then completely read:

- `docs/agent/QT_QUICK_UI.md`
- `docs/agent/ARCHITECTURE.md`
- `docs/agent/NAMING.md`
- `docs/agent/SYNTAX_AND_STYLE.md`
- `docs/agent/API_DESIGN.md`
- `docs/agent/ERRORS_AND_RESOURCES.md`
- `docs/agent/TESTING_AND_VERIFICATION.md`

Inspect the existing UI, CMake targets, tests, and current diff. Before editing,
define user flows, all screen states, reusable components, design tokens,
responsive behavior, keyboard/focus behavior, accessibility, localization, and
the QML/C++ ownership boundary.

Use Qt 6, Qt Quick, QML, Qt Quick Controls, and `qt_add_qml_module`. Keep domain
and application behavior in modern C++ modules. Do not introduce Qt Widgets
without an explicit user request or inspected compatibility requirement.

Implement the smallest coherent UI change, add C++ and relevant QML coverage,
then configure, build, test with zero-tests-as-error, inspect the final diff,
and report exact results and unverified visual states.
