---
description: Verify the requested repository surface without unnecessary rebuilds.
allowed-tools: Read, Bash, Grep, Glob
---

# Test

Read `AGENTS.md`, `docs/agent/EXECUTION_DISCIPLINE.md`, and
`docs/agent/TESTING_AND_VERIFICATION.md`.

If the user names a target, test, component, or changed surface, classify and
run the smallest valid `V1`–`V3` gate. Reuse a compatible configured build tree,
build the affected production target, and run relevant tests/lint/smoke. If
build graph/module/toolchain inputs changed, reconfigure and cover every
affected surface.

If the user requests full/final verification or release readiness, use `V4`:
clean configure, every requested default feature, full default `all` target,
all tests with zero tests treated as an error, and applicable product smoke
checks. Qt `V4` also requires strict `qmllint`, warning-fatal interaction under
the effective Controls style, the required visual acceptance matrix,
`APP_ICONS_AND_BRANDING.md` checks when that surface is in scope, and final
linked runtime plus `qmldir`/`.qmltypes` output evidence.

After a failure, resume from the earliest stage invalidated by the fix instead
of restarting everything. Report exact commands/results, selected level,
per-surface `PASS`/`FAIL`/`NOT VERIFIED`, and all unavailable layers.
