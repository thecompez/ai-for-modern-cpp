# Rule-Driven Review Contract

Review the requested behavior, the final diff, and the verification evidence.
Cite stable rule identifiers from `AGENTS.md` for actionable findings.

## Review Priority

1. Correctness and lost behavior.
2. Safety, ownership, lifetime, and error handling.
3. Architecture and module boundaries.
4. Build, test, and knowledge-contract evidence.
5. Maintainability and documentation.
6. Style only when it violates an explicit repository rule.

## Scope And Discovery

- [ ] `SCP-001`: The owning subsystem and existing behavior were inspected.
- [ ] `SCP-002`: Unrelated human changes were preserved.
- [ ] `SCP-003`: The diff is the smallest coherent complete change.
- [ ] `SCP-004`: No unrelated API rename, dependency, rewrite, or formatting churn exists.

## Architecture And Modules

- [ ] `ARC-001`: Each new behavior has a clear owner.
- [ ] `ARC-002`: Dependency direction remains stable and intentional.
- [ ] `ARC-007`: Repository layout exposes real responsibilities without empty
  layers or dumping grounds.
- [ ] `MOD-001`: New internal production code uses modules.
- [ ] `MOD-002`: Exported declarations are in `.cppm`.
- [ ] `MOD-003`: Non-trivial implementation is in `.cpp`.
- [ ] `MOD-004`: No I/O, platform branch, or large algorithm leaked into an exported interface.
- [ ] `MOD-006`: No unjustified `.h` file was introduced.
- [ ] `MOD-009`: Project-owned `.cppm` modules remain mandatory in every
  standard-library mode.
- [ ] `MOD-010`: `import std` is preferred when supported and standard headers
  are used only as the documented compatibility path.
- [ ] `MOD-011`: Fallback standard headers are in the global module fragment.
- [ ] `MOD-012`: No project-owned header fallback or duplicate source tree was
  introduced.

## Naming And API

- [ ] `NAM-001`: Module names are dotted, lowercase, and domain-oriented.
- [ ] `NAM-002`: Namespaces mirror module identities.
- [ ] `NAM-003`: Types, concepts, and enum enumerators use PascalCase.
- [ ] `NAM-005`: Private/protected data members use `m_`.
- [ ] `NAM-006`: Project-owned data members do not use a trailing underscore.
- [ ] `NAM-009`: Multiword names preserve lowerCamelCase/PascalCase boundaries.
- [ ] `SYN-001`: Leading or trailing return syntax was selected for readability,
  not mechanical uniformity.
- [ ] `SYN-002`: Variables and members have deliberate initial state.
- [ ] `SYN-004`: Enumerations are scoped and every enumerator is PascalCase.
- [ ] `SYN-005`: Null pointers use `nullptr`.
- [ ] `SYN-006`: No C-style cast was introduced.
- [ ] `SYN-015`: Control-flow bodies use braces.
- [ ] `SYN-016`: Class layout presents its contract before private state.
- [ ] `SYN-018`: Constructor initialization follows member declaration order.
- [ ] `SYN-019`: Stored/asynchronous lambda captures have valid lifetimes.
- [ ] `SYN-023`: Ordinary formatted console output uses `std::print` or
  `std::println`.
- [ ] `API-001`: Exported APIs have English Doxygen contracts.
- [ ] `API-002`: Ownership, lifetime, optionality, and failure are explicit.
- [ ] `API-005`: Public templates use meaningful constraints where required.

## Errors, Ownership, And Platforms

- [ ] `ERR-001`: Recoverable failures use `std::expected` or an equivalent.
- [ ] `ERR-004`: No error is swallowed or converted into fake success.
- [ ] `RES-001`: Every acquired resource has deterministic RAII ownership.
- [ ] `RES-002`: No raw owning pointer or scattered cleanup was introduced.
- [ ] `PLT-001`: Platform macros remain at platform boundaries.
- [ ] `PLT-004`: Native resources are isolated behind safe adapters.

## Qt Quick UI

- [ ] `GUI-001`: New Qt UI uses Qt Quick, QML, and Qt Quick Controls.
- [ ] `GUI-002`: Qt Widgets appears only behind an explicit documented exception.
- [ ] `GUI-003`: Domain and application behavior remains in C++ modules.
- [ ] `GUI-004`: QML contains presentation behavior, not authoritative business logic.
- [ ] `GUI-005`: The QML/C++ presentation contract is small and typed.
- [ ] `GUI-007`: Flows, states, components, and design tokens were defined before implementation.
- [ ] `GUI-008`: Layout works beyond one hard-coded window size.
- [ ] `GUI-009`: Keyboard focus and accessibility were considered and verified.
- [ ] `GUI-011`: Work on the GUI thread cannot block interaction.
- [ ] `GUI-012`: QML is registered with `qt_add_qml_module` and target-local Qt dependencies.
- [ ] `GUI-013`: C++ presentation behavior and relevant QML interaction have coverage.
- [ ] `GUI-014`: QObject/QML/RAII ownership is explicit.
- [ ] `GUI-015`: An unspecified user-facing interactive application was not silently reduced to CLI-only.
- [ ] `GUI-016`: Any secondary CLI shares application/domain modules and does not replace or duplicate the primary UI.
- [ ] `GUI-017`: The UI has a product-specific hierarchy and interaction
  rationale rather than a generic repetitive recipe.
- [ ] `GUI-018`: New Qt Quick repositories keep QML and visual assets under an
  explicit top-level `ui/` boundary.

## Build And Tests

- [ ] `BLD-002`: Module interfaces are registered in `CXX_MODULES` file sets.
- [ ] `BLD-003`: CMake changes are target-local.
- [ ] `BLD-005`: `import std` support uses observed toolchain capability.
- [ ] `BLD-008`: Neither language level nor project module architecture was
  silently downgraded.
- [ ] `BLD-010`: Pre-4.0 CMake selects standard headers for GCC in `AUTO` and is
  rejected only by strict `IMPORT_STD` mode.
- [ ] `BLD-011`: Every GNU metadata source resolves or is repaired only in the build tree.
- [ ] `BLD-012`: Compiler-major support is backed by a full CI build, not version assumptions.
- [ ] `BLD-013`: `AUTO`, `IMPORT_STD`, and `HEADERS` are explicit and both
  effective source paths have CI coverage.
- [ ] `TST-001`: Behavior changes have relevant tests.
- [ ] `TST-003`: Invalid, boundary, and failure paths are covered where relevant.
- [ ] `TST-006`: Zero discovered tests are not reported as success.
- [ ] `VER-001`: Configure, build, and tests have separate results.
- [ ] `VER-003`: Exact commands and pass/fail counts are present.
- [ ] `VER-006`: Final diff and `git diff --check` were inspected.

## Knowledge Consistency

- [ ] `KNO-001`: The change teaches agent behavior rather than adding unrelated product features.
- [ ] `KNO-002`: Executable examples still prove the documented rules.
- [ ] `KNO-003`: Incorrect examples are documentation-only and clearly labeled.
- [ ] `KNO-005`: Rules, task guides, review checks, patterns, and evals agree.
- [ ] `DOC-005`: Architecture diagrams match current dependencies.
- [ ] `DOC-008`: Canonical guides use domain-neutral examples unless the domain
  itself is the subject being taught.
- [ ] `VER-007`: The knowledge contract test passed.

## Final Report

- [ ] `REP-001`: Files changed are listed.
- [ ] `REP-002`: What and why are explained.
- [ ] `REP-003`: Configure/build evidence is exact.
- [ ] `REP-004`: Test count and result are exact.
- [ ] `REP-005`: Known limitations are explicit.
- [ ] `REP-006`: Any exception is justified.
- [ ] `REP-007`: Reflected corrections explain the durable lesson.

## Inline Finding Shape

```text
[Priority] RULE-ID — Short title

Explain the concrete defect, the input or environment that triggers it, and the
smallest useful remediation. Keep the line range tight.
```

Do not manufacture findings to fill categories. A clean review may have no
actionable comments.
