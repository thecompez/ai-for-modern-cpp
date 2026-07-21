# Common Failure Catalog

Use this catalog after collecting real command output. Do not select a diagnosis
only because the symptom looks familiar.

| Symptom | Likely cause | Evidence | Correct direction |
|---|---|---|---|
| `CMAKE_CXX_COMPILER_IMPORT_STD=''` | Effective toolchain not recognized for `import std` | CMake/compiler/library/metadata versions | Fix the compatibility unit; do not add includes |
| `module 'std' not found` | Source imports `std` but CMake did not build/provide its BMI | Missing `__cmake_cxx_std_*` target or metadata | Fix module integration and regenerate |
| `libc++.modules.json: File not found` | Compiler returned a basename or stale cache path | Inspect configured metadata path | Associate metadata with the canonical active compiler |
| `build.ninja: No such file` | Configure failed before generation | Earlier CMake error | Fix configure; do not diagnose Ninja separately |
| `No tests were found` after configure failure | No valid test build tree exists | Missing generated test files | Fix configure/build first |
| GCC 15 installed but import list empty | CMake too old or libstdc++ metadata/package mismatch | CMake version and JSON path/content | Use supported CMake and matching libstdc++ |
| Ubuntu GCC 15 with CMake 3.31 | CMake predates GNU `import std` integration | `cmake --version` is 3.31 even though metadata exists | Bootstrap repository-local CMake 4.3.4 |
| Fedora 43 GCC 15 with CMake 3.31 | Fedora's packaged CMake predates GNU `import std` integration | CI reports CMake 3.31 before configure | Bootstrap repository-local CMake 4.3.4 before verification |
| Metadata exists but `std.cc` is missing | Distribution JSON contains a broken relative source path | Resolve each JSON `source-path` from the metadata directory | Use build-tree repaired metadata; never edit `/usr` |
| GCC 16 configure passes but module collation fails | CMake 4.3 scanner is incompatible with the newer GCC module form | `CXX_MODULES` output “does not provide a module interface” | Use verified GCC 15.x or a CMake release verified for GCC 16 |
| Module dependency cycle after source changes | Real import cycle or stale dynamic dependency state | Scanner output and module graph | Fix graph; regenerate cleanly if scanner state is stale |
| Works with `opt/llvm`, fails with `Cellar/llvm` | Path identity comparison used symlink spelling | Canonical compiler and prefix paths | Compare real paths, not display paths |

## Diagnosis Discipline

1. Quote the first causal error.
2. Record exact tool versions and selected paths.
3. Separate observed facts from inference.
4. Prefer the smallest read-only check that can falsify the hypothesis.
5. Do not modify source architecture to work around an unverified packaging
   problem.

## Escalation Evidence

When local diagnosis is insufficient, request only the outputs needed:

```bash
cat /etc/os-release
cmake --version
ninja --version
c++ --version
c++ -print-file-name=libstdc++.modules.json
realpath "$(c++ -print-file-name=libstdc++.modules.json)"
```

Never request tokens, unrelated environment dumps, or broad private filesystem
listings.
