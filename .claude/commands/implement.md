---
description: Implement a requested change using the repository's modern C++ agent loop.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Implement

Use this command when implementing a feature, bug fix, or refactor.

## Required Process

1. Read `AGENTS.md`.
2. For a new product or project, read `docs/agent/START_PROJECT.md`. If its
   human-approved name is missing, ask for it and stop before writing code or
   selecting identifiers.
3. Classify the product surface. An unspecified user-facing interactive
   application uses Qt Quick as its primary interface under `GUI-015`; do not
   silently choose CLI-only.
4. Read the task guides selected by the routing table.
   For a generated Qt Quick/C++ project, begin with
   `docs/agent/PROJECT_CMAKE_BASELINE.md`.
5. Understand the smallest subsystem that owns the requested behavior.
6. Inspect existing module boundaries, tests, and the current diff.
7. Make the smallest correct change.
8. Preserve `.cppm` declaration and `.cpp` implementation separation.
9. Preserve project modules. Put required standard headers in each module
   unit's global module fragment. Do not add experimental standard-library
   module setup.
10. Choose return syntax for readability and use `std::print` or `std::println`
   for ordinary formatted console output.
11. Register `.cppm` files with `FILE_SET CXX_MODULES` and enable target module
    scanning.
12. In a clean final-verification tree, enable every requested default surface,
    build the full default target, run all tests with zero tests treated as an
    error, and run applicable product smoke checks.
13. For Qt Quick work, use one explicit Controls style across application and
    tests, run strict QML lint with zero project warnings, and make runtime QML
    warnings fail a primary interaction that instantiates lazy controls. A
    timer-only launch is insufficient.
14. For a generated Qt Quick project, use source-relative QML paths with
    deterministic resource aliases, keep `ui/` out of module-root aliases, and
    separate the QML output root from the executable runtime output root. Record
    the linked executable plus the generated `qmldir` and `.qmltypes` paths.
15. Fix failures and repeat the complete verification loop.
16. Inspect the final diff and run `git diff --check`.
17. Report a per-surface verification matrix. Do not call a project or archive
    final when a requested primary target is unbuilt or `NOT VERIFIED`.

## Rules

Do not create `.h` files.

Do not use classic header/source architecture for new code.

Do not claim success without running build and tests.
