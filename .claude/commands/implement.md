---
description: Implement a requested change using the repository's modern C++ agent loop.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Implement

Use this command when implementing a feature, bug fix, or refactor.

## Required Process

1. Read `AGENTS.md`.
2. Understand the smallest subsystem that owns the requested behavior.
3. Inspect existing module boundaries.
4. Make the smallest correct change.
5. Preserve `.cppm` declaration and `.cpp` implementation separation.
6. Use C++20+ features appropriately.
7. Build.
8. Run tests.
9. Fix failures.
10. Report exact build and test results.

## Rules

Do not create `.h` files.

Do not use classic header/source architecture for new code.

Do not claim success without running build and tests.
