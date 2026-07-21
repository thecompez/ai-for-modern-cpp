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

When CMake, modules, standard-library integration, or toolchain policy changes,
run separate fresh builds with `AIMCPP_STDLIB_MODE=IMPORT_STD` and
`AIMCPP_STDLIB_MODE=HEADERS`. `AUTO` alone does not prove both source paths.
Fresh configuration is mandatory when pre-`project()` compiler-detection inputs
change; an incremental run may preserve the old capability cache.

Report:

- Configure result.
- Build result.
- Test result.
- Exact failing tests if any.
- Whether failures appear related to the current change.
- Whether the `knowledge_contract` test passed.
