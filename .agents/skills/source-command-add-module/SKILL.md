---
name: "source-command-add-module"
description: "Add a modern C++ module with a documented boundary, CMake registration, and tests."
---

# Add Module

Use this skill when introducing a new project-owned C++ module.

## Required Process

1. Read `AGENTS.md`, `docs/agent/ARCHITECTURE.md`, `MODULES.md`, `NAMING.md`,
   and `SYNTAX_AND_STYLE.md`.
2. Identify the module's single owned responsibility.
3. Choose a dotted lowercase domain-oriented module name.
4. Put exported declarations and Doxygen contracts in `.cppm`.
5. Put non-trivial implementation in `.cpp`.
6. Follow the repository's selected standard-library mode: `import std` when
   enabled, otherwise minimal standard headers in the global module fragment.
7. Register the interface with `FILE_SET CXX_MODULES`.
8. Link consumers to the owning CMake target.
9. Add public-behavior tests.
10. Configure, build, test, inspect the diff, and report exact evidence.

Do not create `.h` files or add a module named `utils`, `helpers`, `common`, or
`misc` without a repository-established domain reason.
