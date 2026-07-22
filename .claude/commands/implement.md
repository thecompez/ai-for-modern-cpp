---
description: Implement a requested change using the repository's modern C++ agent loop.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Implement

Use this command when implementing a feature, bug fix, or refactor.

## Required Process

1. Read `AGENTS.md`.
2. Classify the product surface. An unspecified user-facing interactive
   application uses Qt Quick as its primary interface under `GUI-015`; do not
   silently choose CLI-only.
3. Read the task guides selected by the routing table.
   For a generated Qt Quick/C++ project, begin with
   `docs/agent/PROJECT_CMAKE_BASELINE.md`.
4. Understand the smallest subsystem that owns the requested behavior.
5. Inspect existing module boundaries, tests, and the current diff.
6. Make the smallest correct change.
7. Preserve `.cppm` declaration and `.cpp` implementation separation.
8. Preserve project modules. Put required standard headers in each module
   unit's global module fragment. Do not add experimental standard-library
   module setup.
9. Choose return syntax for readability and use `std::print` or `std::println`
   for ordinary formatted console output.
10. Register `.cppm` files with `FILE_SET CXX_MODULES` and enable target module
    scanning.
11. In a clean final-verification tree, enable every requested default surface,
    build the full default target, run all tests with zero tests treated as an
    error, and run applicable product smoke checks.
12. Fix failures and repeat the complete verification loop.
13. Inspect the final diff and run `git diff --check`.
14. Report a per-surface verification matrix. Do not call a project or archive
    final when a requested primary target is unbuilt or `NOT VERIFIED`.

## Rules

Do not create `.h` files.

Do not use classic header/source architecture for new code.

Do not claim success without running build and tests.
