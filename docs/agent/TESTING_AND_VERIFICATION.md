# Testing And Verification

Use this guide for behavior changes, test design, build claims, and final
reports. Canonical rules: `TST-*`, `VER-*`, and `REP-*`.

## Evidence Layers

| Layer | Question |
|---|---|
| Configure | Can CMake model this source and toolchain? |
| Build | Does the compiler and linker accept the implementation? |
| Unit/behavior tests | Does the public behavior satisfy its contract? |
| Product integration | Did every requested surface and generated source build? |
| Smoke/interaction | Can the primary product surface start and complete its main flow? |
| Visual acceptance | Is the rendered result aligned, balanced, unclipped, and responsive across required states? |
| Knowledge contract | Do rules, guides, examples, and executable proof remain aligned? |
| Diff review | Did the change stay scoped and avoid accidental damage? |

Passing one layer does not imply the others passed.

## Claim Scope

A verification statement is valid only for the features and targets that were
enabled and actually ran. Use a matrix for products with multiple surfaces:

| Surface | Enabled | Evidence | Result |
|---|---:|---|---|
| Domain/application core | yes | core target + behavior tests | PASS/FAIL |
| Qt Quick application | yes | full GUI target, including generated Qt sources | PASS/FAIL |
| QML interaction | yes | QML test or deterministic smoke flow | PASS/FAIL |
| Optional CLI | no | not configured | NOT VERIFIED |

`PASS` for a core library or headless tests cannot be promoted to `PASS` for a
Qt executable that was disabled, skipped because Qt was unavailable, or never
linked. Such a surface is `NOT VERIFIED`.

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

For a Qt Quick product, include all of these layers:

- domain and application behavior, including invalid and boundary input;
- presentation adapter properties, signals, commands, and lifetime;
- QML component creation and the primary interaction flow;
- generated MOC, type-registration, resource, and QML cache compilation;
- a linked graphical executable and a deterministic startup or smoke check;
- keyboard, focus, resizing, important failure states, and accessibility checks
  in proportion to product risk.
- rendered screenshot review at minimum, standard, and wide sizes, including
  meaningful empty, populated, error, focus, long-content, and appearance
  variants;
- deterministic QML geometry checks for critical containment, non-overlap,
  repeated-control metrics, breakpoint selection, and alignment anchors where
  reliable.

## Required Commands

```bash
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build --parallel
ctest --test-dir build --output-on-failure --no-tests=error
git diff --check
```

For a generated Qt project whose GUI and tests are requested, verification uses
a clean tree and explicitly keeps both surfaces enabled:

```bash
cmake -S . -B build/verify -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DMY_APP_BUILD_GUI=ON \
  -DMY_APP_BUILD_TESTS=ON
cmake --build build/verify --parallel --target all
ctest --test-dir build/verify --output-on-failure --no-tests=error
```

Then run the project's QML test or deterministic GUI smoke target. Building an
individual core or test target is useful during iteration, but it is not the
final product gate.

Visual acceptance is also a final product gate. Capture the required screenshot
matrix from the product's layout contract and inspect shared edges, baselines,
spacing rhythm, optical centering, clipping, overlap, truncation, contrast, safe
insets, and accidental dead space. A compiled QML tree can still be visibly
incorrect.

Use a fresh build directory when changing compilers, standard libraries, CMake
major versions, module scanning, or when removing legacy experimental
standard-library module configuration.

There is one standard-library source path: minimal standard headers. Module
changes must verify that `.cppm` interfaces are scanned, built, and imported by
consumers. Do not create parallel builds for obsolete standard-library delivery
modes.

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
Build: PASS — 14/14 steps
Tests: PASS — 2/2 tests
Qt Quick target: PASS — generated registration/resources compiled and executable linked
QML smoke: PASS — exact test or smoke command
Visual acceptance: PASS — exact viewport/state matrix and screenshot evidence
Warnings: none
Unverified: Linux runner not available locally
```

If a required SDK such as Qt is unavailable, report the graphical surface as
`NOT VERIFIED` and stop short of calling the archive ready or final. Never
replace exact evidence with confidence language.
