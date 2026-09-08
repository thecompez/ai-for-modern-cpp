# Testing And Verification

Use this guide for behavior changes, test design, build claims, and final
reports. Canonical rules: `TST-*`, `VER-*`, `REP-*`, and `EFF-*`.

Verification is mandatory when a claim depends on executable behavior, but the
verification depth is adaptive. Passing one evidence layer never implies that a
layer which did not run also passed.

## Evidence Layers

| Layer | Question |
|---|---|
| Configure | Can CMake model this source and toolchain? |
| Build | Does the compiler and linker accept the implementation? |
| Unit/behavior tests | Does the public behavior satisfy its contract? |
| Product integration | Did every requested surface and generated source build? |
| QML static contract | Does strict lint accept every exact type/property/import for the minimum Qt version with zero project warnings? |
| Smoke/interaction | Can the primary product surface start and complete its main flow? |
| Runtime diagnostics | Did the selected Controls style run without project-owned Qt/QML warnings? |
| Visual acceptance | Is the rendered result aligned, balanced, unclipped, and responsive across required states? |
| Knowledge contract | Do rules, guides, examples, and executable proof remain aligned? |
| Diff review | Did the change stay scoped and avoid accidental damage? |

## Verification Levels

Classify every change before final verification.

### V0 — Non-Executable Change

Use for documentation, comments, rule text, and metadata that cannot change
compiled/runtime behavior.

Required:

- inspect the final diff;
- run `git diff --check` when git metadata is available;
- run the knowledge contract or other policy tests when rules/guides/evals
  changed.

Do not configure or build merely to satisfy a ritual. If executable inputs also
changed, this is not `V0`.

### V1 — Presentation-Local Change

Use for isolated QML/presentation/resource work that does not alter C++ public
interfaces, CMake topology, QML registration topology, or dependencies.

Required as applicable:

- build the affected Qt production target when the project compiles/caches or
  packages the changed QML/resources through that target;
- strict `qmllint` for the affected module/components with zero project
  warnings;
- relevant creation/interaction smoke under the effective Controls style;
- targeted rendered visual inspection for visual claims.

Do not clean-configure or rebuild unrelated C++ targets by default.

### V2 — Target-Local Implementation

This is the default for ordinary C++ bug fixes and localized behavior changes.

Required:

- compile/link the smallest affected production target;
- run directly relevant behavior/regression tests;
- run the applicable product smoke path when the changed behavior is only
  observable through integration;
- inspect the final diff.

A production-code change is not compile-verified because only a test helper,
static analysis pass, or unrelated target built.

### V3 — Structural Or Integration Change

Use when changing CMake, module topology, public APIs, dependencies, Qt type
registration/resource topology, platform boundaries, compiler flags, or other
build/integration contracts.

Required:

- configure when build-graph inputs changed;
- build every affected production surface;
- run relevant unit and integration tests;
- run strict lint/smoke/packaging checks for affected product surfaces.

Use a fresh build tree when compiler, standard library, generator, CMake major
version, module scanning, or incompatible build-system state changes. A clean
full-project build is not automatically required if the structural change is
provably isolated to a smaller set of production surfaces, but the evidence
must cover every surface claimed.

### V4 — Final Product Gate

Use for releases, final archives, major milestones, toolchain qualification, or
an explicit full-verification request.

Required:

- clean configure with every requested default product surface enabled;
- build the full default `all` target;
- run all tests with zero tests treated as an error;
- run applicable product startup/interaction smoke checks;
- run strict QML lint and warning-fatal runtime checks for Qt Quick products;
- perform the required visual acceptance matrix for graphical products;
- inspect final outputs and the final diff.

A required primary surface that cannot run is `NOT VERIFIED` and blocks a final
verified artifact.

## Incremental Verification

During implementation, use the smallest gate that can falsify the current
change quickly. Reuse a compatible configured build tree for `V1`/`V2` and
avoid repeated clean configure cycles.

If no compatible build tree exists, configure once with the minimum feature set
that contains the affected production surface.

After a failure, rerun from the earliest stage invalidated by the fix:

```text
source-only compile fix -> build affected target -> relevant tests
QML-only fix            -> relevant lint/target -> relevant smoke
unit-test-only fix       -> affected build if needed -> affected tests
CMake/module graph fix   -> configure -> affected build -> tests
release/final gate       -> clean V4 pipeline
```

Do not repeat configure because a `.cpp` typo changed. Do not rerun every test
because one isolated test expectation changed. Escalate when evidence shows the
change surface is broader than originally classified.

## Claim Scope

A verification statement is valid only for the features and targets that were
enabled and actually ran. Use a matrix for products with multiple surfaces:

| Surface | Enabled | Evidence | Result |
|---|---:|---|---|
| Domain/application core | yes | affected production target + behavior tests | PASS/FAIL |
| Qt Quick application | yes | affected/full GUI target, including generated Qt sources | PASS/FAIL |
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

For a Qt Quick product, the final evidence can include these layers in
proportion to the selected verification level and claim scope:

- domain/application behavior, including invalid and boundary input;
- presentation adapter properties, signals, commands, and lifetime;
- QML component creation and the primary interaction flow;
- generated MOC, type-registration, resource, and QML cache compilation;
- a linked graphical executable and a deterministic startup or smoke check;
- keyboard, focus, resizing, important failure states, and accessibility checks
  in proportion to product risk;
- rendered screenshot review at minimum, standard, and wide sizes when making a
  final polished/responsive claim;
- deterministic QML geometry checks for critical containment, non-overlap,
  repeated-control metrics, breakpoint selection, and alignment anchors where
  reliable;
- strict `qmllint` with a zero project-warning budget under the declared minimum
  Qt version and configured import paths;
- warning-fatal runtime creation under the selected Controls style, covering
  lazy popups, dialogs, delegates, scrollable editors, and responsive branches
  used by the primary flow;
- typography/content-fit checks for missing fonts, longest labels, translated
  expansion, bilingual/RTL popup rows, and focus-ring containment;
- generated QML resource aliases and output roots when those contracts changed
  or when running the `V4` final gate.

## Commands

Prefer project presets when they exist. Otherwise a first configure may use:

```bash
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug
```

Then use targeted build/test commands during `V1`–`V3`, for example:

```bash
cmake --build build --parallel --target <affected-production-target>
ctest --test-dir build -R <relevant-tests> --output-on-failure --no-tests=error
```

For `V4`, use a clean final-verification directory and the full default target:

```bash
cmake -S . -B build/verify -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug
cmake --build build/verify --parallel --target all
ctest --test-dir build/verify --output-on-failure --no-tests=error
git diff --check
```

For a generated Qt project whose GUI and tests are part of the final gate,
explicitly keep both surfaces enabled:

```bash
cmake -S . -B build/verify -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DMY_APP_BUILD_GUI=ON \
  -DMY_APP_BUILD_TESTS=ON
cmake --build build/verify --parallel --target all
cmake --build build/verify --parallel --target MyApp_qmllint_strict
ctest --test-dir build/verify --output-on-failure --no-tests=error
```

Then run the project's QML interaction or deterministic GUI smoke target with
the same effective Controls style as the application and project-owned Qt/QML
warnings treated as failures. The smoke flow must await explicit readiness and
exercise the primary path. A fixed-delay launch that never opens lazy controls
does not verify the product.

For the canonical generated-project fixture, also verify actual filesystem
outputs after the final link:

```text
build/verify/bin/MyApp               # .exe or bundle-internal target as applicable
build/verify/qml/MyApp/qmldir
build/verify/qml/MyApp/MyApp.qmltypes
```

The fixture deliberately uses `MyApp` for both executable target and QML URI.
It must clean-configure, build the full default target, compile project modules,
MOC, registration, RCC, and QML cache sources, link the executable, run strict
module lint, and load module-root `Main` in a warning-fatal readiness smoke when
performing its final integration gate. If Qt is unavailable, record this
fixture as `NOT VERIFIED`; do not infer it from non-Qt core tests.

Visual acceptance is a final product gate for a claim that a graphical UI is
polished/responsive. Inspect shared edges, baselines, spacing rhythm, optical
centering, clipping, overlap, truncation, contrast, safe insets, and accidental
dead space across the required viewport/state matrix.

## Failure Classification

Report the first causal failure. Later failures may be consequences.

```text
Configure failed
    -> build.ninja was never generated
        -> build cannot start
            -> CTest may find no tests
```

Only the configure failure is the root cause in this sequence.

## Final Evidence Format

```text
Verification level: V2 — target-local C++ behavior change
Configure: NOT RUN — compatible build tree reused
Build: PASS — exact affected target command
Tests: PASS — exact relevant command and count
Qt Quick target: NOT APPLICABLE
Warnings: none
Unverified: Windows CI not available in this local environment
```

For a `V4` Qt product report, additionally include:

```text
Verification level: V4 — final product gate
Configure: PASS — exact clean command
Build: PASS — full default target
Tests: PASS — exact count
Qt Quick target: PASS — generated registration/resources compiled and executable linked
QML smoke: PASS — exact test or smoke command
QML lint: PASS — exact strict command, 0 project warnings
Qt runtime diagnostics: PASS — effective Controls style, 0 project warnings
Generated outputs: PASS — runtime path + QML qmldir/.qmltypes paths
Visual acceptance: PASS — exact viewport/state matrix and screenshot evidence
```

If a required SDK is unavailable or the user explicitly prohibits a required
verification stage, report that surface as `NOT VERIFIED`. Never replace exact
evidence with confidence language.
