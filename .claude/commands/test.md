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
