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
4. Understand the smallest subsystem that owns the requested behavior.
5. Inspect existing module boundaries, tests, and the current diff.
6. Make the smallest correct change.
7. Preserve `.cppm` declaration and `.cpp` implementation separation.
8. Preserve project modules in both standard-library modes and keep fallback
   standard headers in global module fragments.
9. Choose return syntax for readability and use `std::print` or `std::println`
   for ordinary formatted console output.
10. Build and run tests with zero tests treated as an error.
11. Fix failures and repeat verification.
12. Inspect the final diff and run `git diff --check`.
13. Report exact build and test results.

## Rules

Do not create `.h` files.

Do not use classic header/source architecture for new code.

Do not claim success without running build and tests.
