---
name: "source-command-test"
description: "Verify a repository at the requested scope without unnecessary rebuilds or fabricated evidence."
---

# source-command-test

Read `AGENTS.md`, `docs/agent/EXECUTION_DISCIPLINE.md`, and
`docs/agent/TESTING_AND_VERIFICATION.md`.

## Scope

- If the user names a target, test, component, bug, or changed surface, classify
  the required gate as `V1`–`V3` and verify that scope.
- If the user asks for a complete/final verification, release readiness, or
  gives no narrower scope while explicitly invoking the full test workflow, use
  `V4`.
- Do not broaden a targeted verification into unrelated full-project work merely
  because additional targets exist.

Prefer repository presets when available.

For `V1`/`V2`, reuse a compatible configured tree, build the affected production
target, and run directly relevant tests/lint/smoke. Configure once if no
compatible tree exists.

For `V3`, rerun configure when build-graph/module/toolchain inputs changed, then
build every affected production surface and run relevant integration checks.

For `V4`, use a clean final-verification directory, keep every requested default
feature enabled, build the full default `all` target, and run all tests with zero
tests treated as an error. For Qt products, confirm the graphical executable
links after generated MOC, QML registration, resource, and cache sources;
run strict lint, warning-fatal interaction smoke, and the required visual
acceptance matrix. Verify deterministic resource aliases and separate QML/runtime
output roots, and record the linked executable, `qmldir`, and `.qmltypes` paths.
Application-icon/branding verification must follow
`docs/agent/APP_ICONS_AND_BRANDING.md` when that surface is in scope.

If a command fails, fix or diagnose the first causal failure and resume from the
earliest invalidated stage; do not automatically restart the complete pipeline.

Report:

- selected verification level and rationale;
- configure/build/test/lint/smoke commands that actually ran;
- exact pass/fail counts where applicable;
- affected surface/target matrix with `PASS`, `FAIL`, or `NOT VERIFIED`;
- visual acceptance matrix when required;
- Qt version/style/warning counts and lazy components when Qt verification ran;
- linked runtime, `qmldir`, and `.qmltypes` paths for final generated-Qt gates;
- every skipped or unavailable layer as `NOT VERIFIED`.
