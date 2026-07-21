# Testing And Verification

Use this guide for behavior changes, test design, build claims, and final
reports. Canonical rules: `TST-*`, `VER-*`, and `REP-*`.

## Evidence Layers

| Layer | Question |
|---|---|
| Configure | Can CMake model this source and toolchain? |
| Build | Does the compiler and linker accept the implementation? |
| Unit/behavior tests | Does the public behavior satisfy its contract? |
| Knowledge contract | Do rules, guides, examples, and executable proof remain aligned? |
| Diff review | Did the change stay scoped and avoid accidental damage? |

Passing one layer does not imply the others passed.

## Test Selection

Add tests for:

- new observable behavior;
- invalid and boundary input;
- expected failure values;
- invariants and construction failure;
- move/ownership behavior when resource types change;
- platform translation at supported boundaries;
- regressions reproduced by a prior failure.

Avoid tests that expose private helpers solely for access. Prefer public module
behavior.

## Required Commands

```bash
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build --parallel
ctest --test-dir build --output-on-failure --no-tests=error
git diff --check
```

Use a fresh build directory when changing compilers, standard libraries, CMake
major versions, or module metadata.

## Failure Classification

Report the first causal failure. Later failures may be consequences.

```text
Configure failed
    → build.ninja was never generated
        → build cannot start
            → CTest may find no tests
```

Only the configure failure is the root cause in this sequence.

## Final Evidence Format

```text
Configure: PASS — exact command
Build: PASS — 20/20 steps
Tests: PASS — 2/2 tests
Warnings: two upstream libc++ experimental module warnings
Unverified: Linux runner not available locally
```

Never replace exact evidence with confidence language.
