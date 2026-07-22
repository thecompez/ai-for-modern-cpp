---
description: Build and test the repository without making unnecessary code changes.
allowed-tools: Read, Bash, Grep, Glob
---

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
enabled, and build the full default `all` target. For Qt products, confirm the
graphical executable links after generated MOC, QML registration, resource, and
QML cache sources compile, then run a QML interaction or deterministic startup
smoke check. A core-only or GUI-disabled build does not verify the application.

For graphical products, capture and inspect minimum, standard, and wide
screenshots across relevant appearance/content states. Check shared edges,
baselines, repeated metrics, spacing rhythm, clipping, overlap, truncation,
optical centering, contrast, safe insets, and accidental dead space. Run
deterministic QML geometry checks where practical.

For Qt Quick, run strict `qmllint` with zero project warnings and a warning-fatal
interaction smoke under the same explicit Controls style as the application.
The flow must reach explicit readiness and instantiate primary-path popups,
dialogs, delegates, editors, and responsive branches; a timer-only launch is
insufficient. Reject invalid properties, unsupported style customization,
binding loops, missing-font warnings, clipped popup content, and truncated
primary actions.

For CMake, module, or toolchain-policy changes, use a fresh build directory and
verify the single supported standard-library path: project modules plus minimal
standard headers in global module fragments.

Report:

- Configure result.
- Build result.
- Test result.
- Exact failing tests if any.
- Whether failures appear related to the current change.
- Whether the `knowledge_contract` test passed.
- A per-surface `PASS`, `FAIL`, or `NOT VERIFIED` matrix.
- A viewport/appearance/content-state visual acceptance matrix.
- The minimum Qt version, effective Controls style, lint/runtime warning counts,
  and lazy components exercised by the interaction flow.

Do not describe a project or archive as final while a requested primary surface
is unbuilt or `NOT VERIFIED` because its SDK or runtime was unavailable.
