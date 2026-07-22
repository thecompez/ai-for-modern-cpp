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
   Generated Qt Quick/C++ projects must read and start from
   `docs/agent/PROJECT_CMAKE_BASELINE.md`.
4. Understand the smallest subsystem that owns the requested behavior.
5. Inspect existing module boundaries, tests, working tree, and current diff.
6. Make the smallest correct change.
7. Preserve `.cppm` declaration and `.cpp` implementation separation.
8. Preserve project modules. Put required standard headers in each module
   unit's global module fragment. Do not add experimental standard-library
   module setup.
9. Use C++20+ features appropriately, choose return syntax for readability,
   and prefer `std::print` or `std::println` for ordinary formatted output.
10. Keep CMake on the deterministic standard-header path: register `.cppm`
    files with `FILE_SET CXX_MODULES` and enable target module scanning.
11. In a clean final-verification tree, enable every requested default product
    surface and build the full default target. A core-only target cannot verify
    an unbuilt GUI.
12. Run all tests with zero discovered tests treated as an error, plus the
    applicable product startup or interaction smoke checks.
13. Fix failures and repeat the complete verification loop.
14. Inspect the final diff and run `git diff --check`.
15. Report a target-by-target verification matrix. Do not label an archive
    final while a requested primary surface is `NOT VERIFIED`.

## Rules

Do not create `.h` files.

Do not use classic header/source architecture for new code.

Do not claim success without running build and tests.

For policy or documentation changes, the `knowledge_contract` test is required.
