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
2. Classify the product surface. For an unspecified user-facing interactive
   application, apply `GUI-015`, read the Qt Quick guides, and use Qt Quick as
   the primary interface rather than silently selecting CLI-only.
3. Use the task-routing table and read every selected guide completely.
4. Understand the smallest subsystem that owns the requested behavior.
5. Inspect existing module boundaries, tests, working tree, and current diff.
6. Make the smallest correct change.
7. Preserve `.cppm` declaration and `.cpp` implementation separation.
8. Preserve project modules in both standard-library modes; place fallback
   standard headers only in global module fragments.
9. Use C++20+ features appropriately, choose return syntax for readability,
   and prefer `std::print` or `std::println` for ordinary formatted output.
10. Build.
11. Run tests with zero discovered tests treated as an error.
12. Fix failures and repeat verification.
13. Inspect the final diff and run `git diff --check`.
14. Report exact build and test results.

## Rules

Do not create `.h` files.

Do not use classic header/source architecture for new code.

Do not claim success without running build and tests.

For policy or documentation changes, the `knowledge_contract` test is required.
