---
description: Implement a requested change with bounded context and adaptive verification.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Implement

Read `AGENTS.md` and `docs/agent/EXECUTION_DISCIPLINE.md`. Route only to guides
required by the actual task. For a new product/project, apply the project-name
gate before writing files.

Inspect the current diff, owning subsystem, directly relevant source/tests, and
build target. Work as one agent by default. Classify the change `V0` through
`V4` using `docs/agent/TESTING_AND_VERIFICATION.md`, then make the smallest
coherent change while preserving C++ modules, `.cppm` declarations, `.cpp`
implementations, standard headers in the global module fragment, and target-local CMake
module scanning where applicable.

Verify incrementally. Reuse a compatible configured tree for `V1`/`V2`; compile
the affected production target and run relevant tests/lint/smoke. Reconfigure
for `V3` when graph inputs changed. Use a clean tree, full default target, all
tests, and applicable Qt lint/smoke/visual gates only for `V4` or when structural
state requires it. A final generated Qt gate records the linked runtime,
`qmldir`, and `.qmltypes` paths.

After a failure, fix the first causal error and rerun from the earliest stage
invalidated by that fix; do not repeat the complete verification loop by
habit. Inspect the final diff, run `git diff --check` when available, report the
verification level, exact evidence and every `NOT VERIFIED` layer, then stop.

Do not create new project-owned `.h` files or classic header/source architecture.
Do not claim a production surface passed unless the required evidence actually
ran.
