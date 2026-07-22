---
name: "source-command-test"
description: "Build and test the repository without making unnecessary code changes."
---

# source-command-test

Use this skill when the user asks to run the migrated source command `test`.

## Command Template

# Test

Run the repository verification loop.

Preferred commands:

```bash
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build --parallel
ctest --test-dir build --output-on-failure --no-tests=error
```

If presets exist, prefer the repository presets.

Use a clean final-verification directory, keep every requested default feature
enabled, and build the full default `all` target. For a Qt product, confirm the
graphical executable links after generated MOC, QML type-registration,
resource, and QML cache sources compile. Then run QML creation/interaction or a
deterministic GUI startup smoke check. A GUI-disabled core build is partial
evidence, not product verification.

For a graphical product, capture and inspect the required minimum, standard,
and wide screenshot matrix across relevant appearance and content states. Check
containment, overlap, clipping, shared edges, baselines, repeated metrics,
spacing rhythm, optical centering, contrast, safe insets, and accidental dead
space. Run deterministic QML geometry assertions where practical.

Run the strict QML lint target with zero project warnings. Run the GUI/QML
interaction smoke under the same explicit Controls style as the application,
with project-owned Qt/QML warnings treated as failures. The flow must reach an
explicit ready state and instantiate primary-path lazy popups, dialogs,
delegates, editors, and responsive branches; a timer-only launch is not product
verification. Reject invalid properties, unsupported style customization,
binding loops, missing-font substitution, clipped popup rows, and truncated
primary actions.

When CMake, modules, standard-library integration, or toolchain policy changes,
use a fresh build directory and verify the single supported path: project-owned
modules plus standard headers in global module fragments.

Report:

- Configure result.
- Build result.
- Test result.
- Exact failing tests if any.
- Whether failures appear related to the current change.
- Whether the `knowledge_contract` test passed.
- A surface/target matrix with `PASS`, `FAIL`, or `NOT VERIFIED`.
- The viewport/appearance/content-state visual acceptance matrix.
- The minimum Qt version, effective Controls style, strict lint warning count,
  runtime warning count, and lazy components exercised by the smoke flow.

If a required SDK is unavailable, report the affected primary surface as
`NOT VERIFIED`; do not describe the project or archive as ready or final.
