---
name: "source-command-implement"
description: "Implement the smallest verified change with adaptive verification and bounded agent execution."
---

# source-command-implement

Use this skill for a feature, bug fix, or refactor.

## Required Process

1. Read `AGENTS.md` and `docs/agent/EXECUTION_DISCIPLINE.md`.
2. When creating a new product/project, apply `INI-001` through `INI-004` and
   read `docs/agent/START_PROJECT.md`. If the name is missing, ask and stop.
3. Use the task-routing table. Read only guides required by the actual touched
   concerns; do not load every guide by default.
4. Inspect the current diff/working tree, locate the owning subsystem, and read
   the directly relevant implementation, tests, and build target.
5. Classify the change as `V0` through `V4` using
   `docs/agent/TESTING_AND_VERIFICATION.md`.
6. Work as one agent by default. Do not launch routine parallel reviewers or
   exploratory subagents.
7. Make the smallest coherent change. Preserve unrelated human work.
8. Preserve `.cppm` declaration and `.cpp` implementation separation. Put
   required standard headers in the global module fragment; do not add
   experimental standard-library module setup.
9. Register changed/new modules with `FILE_SET CXX_MODULES` and target-local
   scanning when the task touches module topology.
10. Verify incrementally:
    - `V0`: contract/diff checks only as applicable;
    - `V1`: affected Qt target when applicable + relevant QML lint/smoke/visual;
    - `V2`: affected production target + directly relevant tests/smoke;
    - `V3`: configure when graph inputs changed + all affected production
      surfaces + relevant integration checks;
    - `V4`: clean final-verification tree, every requested default surface,
      full default `all` target, all tests, and applicable lint/smoke/visual
      gates.
11. Reuse a compatible configured build tree for `V1`/`V2`. If none exists,
    configure once with the minimum feature set that includes the affected
    production surface.
12. If verification fails, fix the first causal failure and rerun from the
    earliest stage invalidated by the fix. Do not repeat the complete pipeline
    unnecessarily.
13. For Qt Quick work, preserve one explicit Controls style across app/tests;
    use strict `qmllint` and warning-fatal runtime smoke to the depth required
    by the selected level. Final Qt `V4` evidence includes the linked runtime,
    generated `qmldir`, `.qmltypes`, and required visual acceptance matrix.
14. Inspect the final diff and run `git diff --check` when git metadata is
    available.
15. Report the selected verification level, exact evidence, files changed,
    limitations, and every `NOT VERIFIED` layer, then stop.

## Rules

Do not create `.h` files for new project-owned code.

Do not use classic header/source architecture for new internal code.

Do not claim success for a production surface that was not actually built or
otherwise verified at the required layer.
