---
name: "source-command-implement"
description: "Implement a requested change using the repository's modern C++ agent loop."
---

# source-command-implement

Use this skill when the user asks to run the migrated source command `implement`.

## Command Template

# Implement

Use this command when implementing a feature, bug fix, or refactor.

## Required Process

1. Read `AGENTS.md`.
2. Use its task-routing table and read every selected guide completely.
3. Understand the smallest subsystem that owns the requested behavior.
4. Inspect existing module boundaries, tests, working tree, and current diff.
5. Make the smallest correct change.
6. Preserve `.cppm` declaration and `.cpp` implementation separation.
7. Use C++20+ features appropriately.
8. Build.
9. Run tests with zero discovered tests treated as an error.
10. Fix failures and repeat verification.
11. Inspect the final diff and run `git diff --check`.
12. Report exact build and test results.

## Rules

Do not create `.h` files.

Do not use classic header/source architecture for new code.

Do not claim success without running build and tests.

For policy or documentation changes, the `knowledge_contract` test is required.
