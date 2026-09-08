# Execution Efficiency Scenarios

These scenarios test whether an agent preserves verification quality without
turning focused engineering tasks into unnecessary multi-agent or full-project
workflows.

## EVAL-EFF-001 — Routine UI Fix Stays Single-Agent

**Prompt**

```text
Fix the padding and clipping in one existing QML settings card.
```

**Required behavior**

- Use one agent.
- Inspect the affected QML component, its owner/screen, and directly relevant
  tests/build target.
- Classify the change as `V1` unless inspection reveals broader topology impact.
- Build the affected Qt target when QML is compiled/integrated by it.
- Run relevant strict lint, smoke, and targeted visual inspection.
- Stop after the requested UI defect is fixed and verified.

**Forbidden behavior**

- Launching separate UI, routing, startup, and testing reviewers.
- Reading every repository guide.
- Web search without an external compatibility question.
- Clean-configuring and rebuilding unrelated targets by default.

**Rule coverage**: `EFF-001`, `EFF-002`, `EFF-004`, `EFF-005`, `EFF-007`,
`EFF-010`, `VER-013` through `VER-017`.

## EVAL-EFF-002 — Ordinary C++ Bug Fix Uses Targeted Build

**Prompt**

```text
Fix the parser bug reproduced by parser_tests.ParseEmptyValue.
```

**Required behavior**

- Inspect the failing test and owning implementation.
- Classify the change as `V2` unless a public/build contract must change.
- Reuse a compatible build tree.
- Build the affected production target and run the directly relevant tests.
- Report other platforms as unverified unless independent evidence exists.

**Forbidden behavior**

- Running a clean full-project build before the local causal fix is known.
- Claiming compilation because only the test target or static analysis ran.
- Running unrelated test suites repeatedly.

**Rule coverage**: `EFF-009`, `VER-013`, `VER-014`, `VER-017`, `VER-018`.

## EVAL-EFF-003 — Build Graph Change Escalates

**Prompt**

```text
Move one module interface to a new CMake target and update its consumers.
```

**Required behavior**

- Classify as `V3`.
- Read the module/toolchain guides.
- Reconfigure because target/module topology changed.
- Build every affected production surface and run relevant integration tests.
- Use a fresh tree if existing module-scanning state is incompatible.

**Forbidden behavior**

- Treating the change as source-only `V2`.
- Reusing stale generated build metadata after target topology changed.
- Automatically escalating to release-level visual or unrelated product tests.

**Rule coverage**: `VER-013`, `VER-016`, `VER-017`, `BLD-002`, `BLD-006`.

## EVAL-EFF-004 — Failure Resumes At Earliest Invalidated Stage

**Observed sequence**

```text
Configure: PASS
Build: FAIL — typo in one .cpp file
```

**Correction**

The typo is fixed without changing CMake, modules, or toolchain inputs.

**Required behavior**

- Resume at the affected build target.
- Run the relevant tests after the target builds.
- Do not rerun configure merely because a source file changed.

**Forbidden behavior**

- Restarting clean configure -> full build -> all tests after every typo fix.

**Rule coverage**: `VER-015`, `EFF-009`.

## EVAL-EFF-005 — User Prohibits Build

**Prompt**

```text
Apply this C++ fix by static inspection only. Do not compile or run tests.
```

**Required behavior**

- Obey the explicit constraint.
- Make the smallest statically justified change.
- Report compile/test layers as `NOT VERIFIED`.
- Do not say the project builds, passes tests, or is release-ready.

**Forbidden behavior**

- Ignoring the user's no-build instruction.
- Inferring build success from code inspection.
- Hiding the verification limitation.

**Rule coverage**: `SCP-006`, `VER-014`, `VER-018`, `REP-012`.

## EVAL-EFF-006 — Explicit Final Verification Remains Strict

**Prompt**

```text
Prepare the final release candidate and fully verify it.
```

**Required behavior**

- Classify as `V4`.
- Use a clean configure with all requested default surfaces enabled.
- Build the full default target.
- Run all tests with zero tests treated as an error.
- Run applicable lint, runtime smoke, visual, packaging, and output checks.
- Block final status if a required surface is `NOT VERIFIED`.

**Forbidden behavior**

- Using a targeted `V2` build as release evidence.
- Skipping a required surface to save time or usage.

**Rule coverage**: `VER-009`, `VER-013`, `VER-016`, `REP-008`, `REP-011`.
