---
description: Implement a requested change using the repository's modern C++ agent loop.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Implement

Use this command when implementing a feature, bug fix, or refactor.

## Required Process

1. Read `AGENTS.md`.
2. Read the task guides selected by its routing table.
3. Understand the smallest subsystem that owns the requested behavior.
4. Inspect existing module boundaries, tests, and the current diff.
5. Make the smallest correct change.
6. Preserve `.cppm` declaration and `.cpp` implementation separation.
7. Build and run tests with zero tests treated as an error.
8. Fix failures and repeat verification.
9. Inspect the final diff and run `git diff --check`.
10. Report exact build and test results.

## Rules

Do not create `.h` files.

Do not use classic header/source architecture for new code.

Do not claim success without running build and tests.
