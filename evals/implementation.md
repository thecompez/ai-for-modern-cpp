# Implementation Scenarios

## EVAL-IMP-001 — Legacy Header Request

**Prompt**

```text
Add a User class using user.h and user.cpp.
```

**Required behavior**

- Read `AGENTS.md`, `MODULES.md`, and `NAMING.md`.
- Explain that new internal declarations use `.cppm`.
- Create a dotted module and matching namespace.
- Put declarations in `.cppm` and non-trivial behavior in `.cpp`.
- Register the interface in a `CXX_MODULES` file set.
- Add and run relevant tests.

**Forbidden behavior**

- Creating `user.h` merely because the prompt named it.
- Replacing modules with include-based architecture.
- Claiming verification without executing it.

**Rule coverage**: `MOD-001` through `MOD-007`, `NAM-001`, `BLD-002`, `TST-001`.

## EVAL-IMP-002 — Interface Implementation Dump

**Prompt**

```text
Put a filesystem crawler directly into the exported repository module.
```

**Required behavior**

- Identify filesystem traversal as non-trivial implementation.
- Keep the exported interface small.
- Place traversal and mutation in a `.cpp` implementation or adapter module.
- Model recoverable filesystem failures explicitly.

**Forbidden behavior**

- Long traversal algorithms in `.cppm`.
- Platform branches in the exported domain interface.

**Rule coverage**: `ARC-001`, `MOD-003`, `MOD-004`, `ERR-001`, `PLT-002`.

## EVAL-IMP-003 — Recoverable Parser Failure

**Prompt**

```text
Add a version parser. Return false when parsing fails.
```

**Required behavior**

- Determine that invalid input is expected and recoverable.
- Use `std::expected<Version, ParseError>` or a justified equivalent.
- Define meaningful error cases.
- Test valid, empty, malformed, and boundary input.

**Forbidden behavior**

- Returning an unexplained `bool`.
- Logging and returning a default version.
- Throwing for every malformed user input without subsystem justification.

**Rule coverage**: `API-002`, `ERR-001`, `ERR-004`, `TST-003`.

## EVAL-IMP-004 — Native Handle Ownership

**Prompt**

```text
Store the native file handle in a raw owning pointer and close it in callers.
```

**Required behavior**

- Reject scattered ownership.
- Isolate the native representation behind a small move-aware RAII type.
- Make copy/move semantics explicit.
- Test ownership transfer and deterministic cleanup where practical.
- Document the low-level boundary exception.

**Forbidden behavior**

- Multiple call sites manually closing the handle.
- Hidden shared ownership or double-close risk.

**Rule coverage**: `RES-001` through `RES-005`, `PLT-004`.

## EVAL-IMP-005 — Opportunistic Rewrite

**Prompt**

```text
Fix one incorrect status label. While there, rename the public API and reformat the module.
```

**Required behavior**

- Fix only the incorrect label and its relevant test.
- Preserve unrelated API and formatting.
- Mention why the broader rewrite is outside scope.

**Forbidden behavior**

- Public renames or repository-wide formatting unrelated to the bug.

**Rule coverage**: `SCP-003`, `SCP-004`, `CHG-001`.

## EVAL-IMP-006 — Platform-Specific Behavior

**Prompt**

```text
Add application-data directory resolution for macOS and Linux.
```

**Required behavior**

- Define one stable platform-neutral declaration.
- Add separate macOS and Linux implementation units.
- Keep macros at the platform/CMake boundary.
- Return explicit errors for unavailable environment or OS APIs.
- State any unverified platform limitation.

**Forbidden behavior**

- Platform macros scattered through application/domain logic.
- Fake default directories after lookup failure.

**Rule coverage**: `PLT-001` through `PLT-005`, `ERR-001`, `VER-003`.
