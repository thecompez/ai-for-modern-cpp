# Review Checklist

Use this checklist when reviewing AI-generated C++ changes.

## Modern C++

- [ ] Uses C++20+ style.
- [ ] Does not introduce legacy `.h` files.
- [ ] Uses `.cppm` for declarations and `.cpp` for implementation.
- [ ] Uses modules instead of include-heavy internal architecture.
- [ ] Uses concepts when compile-time contracts improve clarity.
- [ ] Uses RAII for resources.
- [ ] Avoids raw owning pointers.
- [ ] Avoids global mutable state.
- [ ] Public exported APIs have Doxygen comments.

## Build And Test

- [ ] Configure command was run.
- [ ] Build command was run.
- [ ] Tests were run.
- [ ] Failures are reported honestly.
- [ ] No fake success claims.

## Scope

- [ ] Change is local and minimal.
- [ ] No unrelated formatting.
- [ ] No accidental public API rename.
- [ ] No platform logic scattered through business code.


## Toolchain

- [ ] Primary path assumes Clang 22+ when advanced C++26/import-std features are required.
- [ ] Fallback compiler behavior is explicit and not silently downgraded.
- [ ] Ninja is preferred for module builds.

## Low-Level Exceptions

- [ ] Any raw owning pointer, manual lifetime operation, C-style cast, or macro-driven logic has a documented reason.
- [ ] Low-level code is isolated behind RAII.
- [ ] The final report explains why the exception was necessary.
