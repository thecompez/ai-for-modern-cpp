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
2. When this request creates a new product or project, apply `INI-001` through
   `INI-004` and read `docs/agent/START_PROJECT.md`. If the project name is
   missing, ask for it and stop before writing code or choosing identifiers.
3. Classify the product surface. For an unspecified user-facing interactive
   application, apply `GUI-015`, read the Qt Quick guides, and use Qt Quick as
   the primary interface rather than silently selecting CLI-only.
4. Use the task-routing table and read every selected guide completely.
   Generated Qt Quick/C++ projects must read and start from
   `docs/agent/PROJECT_CMAKE_BASELINE.md`.
5. Understand the smallest subsystem that owns the requested behavior.
6. Inspect existing module boundaries, tests, working tree, and current diff.
7. Make the smallest correct change.
8. Preserve `.cppm` declaration and `.cpp` implementation separation.
9. Preserve project modules. Put required standard headers in each module
   unit's global module fragment. Do not add experimental standard-library
   module setup.
10. Use C++20+ features appropriately, choose return syntax for readability,
   and prefer `std::print` or `std::println` for ordinary formatted output.
11. Keep CMake on the deterministic standard-header path: register `.cppm`
    files with `FILE_SET CXX_MODULES` and enable target module scanning.
12. In a clean final-verification tree, enable every requested default product
    surface and build the full default target. A core-only target cannot verify
    an unbuilt GUI.
13. Run all tests with zero discovered tests treated as an error, plus the
    applicable product startup or interaction smoke checks.
14. Fix failures and repeat the complete verification loop.
15. Inspect the final diff and run `git diff --check`.
16. Report a target-by-target verification matrix. Do not label an archive
    final while a requested primary surface is `NOT VERIFIED`.

## Rules

Do not create `.h` files.

Do not use classic header/source architecture for new code.

Do not claim success without running build and tests.

For policy or documentation changes, the `knowledge_contract` test is required.
