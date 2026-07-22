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

- [ ] `INI-001`: New product or project creation began only after the human
  approved an unambiguous project name.
- [ ] `INI-002`: No files or technical identities were created while the name
  was unresolved.
- [ ] `INI-003`: Named requests and established repositories were not blocked
  by a redundant question, and placeholders were not treated as approval.
- [ ] `INI-004`: External use of this repository records the exact revision and
  routed guides actually read.
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
- [ ] `MOD-009`: Project-owned boundaries remain `.cppm` modules.
- [ ] `MOD-010`: Standard-library dependencies use minimal standard headers;
  experimental `import std;` is absent.
- [ ] `MOD-011`: Standard headers in module units are in the global module
  fragment.
- [ ] `MOD-012`: Standard headers did not become an excuse for project-owned
  header fallback or a duplicate source tree.

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
- [ ] `GUI-019`: QTP0004 is selected with a minimum-version-compatible guard
  before QML module registration, and missing generated `.qmltypes` diagnostics
  are not mistaken for an earlier Generate failure.
- [ ] `GUI-020`: Nested `QML_ELEMENT` adapter headers are reachable through the
  owning QML target's include directories; generated registration files are not
  edited.
- [ ] `GUI-021`: A QML-creatable QObject is not `final`; any final presentation
  type has an explicit non-creatable registration and ownership strategy.
- [ ] `GUI-022`: At least one clean Qt-enabled full build compiled generated Qt
  sources and linked the requested graphical executable.
- [ ] `GUI-023`: The screen has a documented layout contract covering bounds,
  columns, gutters, shared alignment lines, spacing, repeated metrics, safe
  insets, and region sizing behavior.
- [ ] `GUI-024`: Repeated controls and parallel regions preserve intentional
  edge, center, baseline, size, and gap relationships.
- [ ] `GUI-025`: Compact, standard, and wide compositions avoid accidental dead
  space, edge-pinned task content, clipping, and unbounded stretching.
- [ ] `GUI-026`: Rendered screenshots passed a detail review across required
  sizes, appearance modes, and representative content states.
- [ ] `GUI-027`: Every QML API is valid on the exact instantiated type and
  declared minimum Qt version; strict lint and runtime creation both pass.
- [ ] `GUI-028`: The Controls style strategy is explicit; custom delegates use
  a supported customizable style selected before QML loads, or native controls
  stay within their documented customization surface.
- [ ] `GUI-029`: Geometry dependencies are acyclic, especially across
  ScrollView/editor content and implicit-size boundaries; no binding loop is
  accepted.
- [ ] `GUI-030`: Primary labels, translated text, popup/delegate rows, RTL or
  bilingual content, icons, indicators, focus rings, and hit targets remain
  readable, contained, and aligned.
- [ ] `GUI-031`: Fonts are system-resolved or bundled/licensed with verified
  fallbacks; no missing-font substitution warning remains.
- [ ] `GUI-032`: Strict lint and warning-fatal runtime interaction cover lazy
  controls and the primary flow; a timer-only launch is not the smoke gate.
- [ ] `GUI-033`: QML sources are project-relative and receive deterministic
  aliases before module registration; `ui/` is removed from resource identity,
  logical subdirectories remain, and module-root `Main` still loads.

## Build And Tests

- [ ] `BLD-002`: Module interfaces are registered in `CXX_MODULES` file sets.
- [ ] `BLD-003`: CMake changes are target-local.
- [ ] `BLD-004`: Project module targets enable `CXX_SCAN_FOR_MODULES` without
  enabling standard-library modules.
- [ ] `BLD-005`: No experimental standard-library module gate, capability probe,
  or metadata path remains.
- [ ] `BLD-008`: Neither language level nor project module architecture was
  silently downgraded.
- [ ] `BLD-010`: Toolchain guidance verifies project modules and does not
  require newer CMake solely for standard-library modules.
- [ ] `BLD-011`: No libc++ or libstdc++ module metadata is located or rewritten.
- [ ] `BLD-012`: Compiler-major support is backed by a full CI build, not version assumptions.
- [ ] `BLD-013`: Standard-library integration has one deterministic header path
  and no delivery-mode option.
- [ ] `BLD-014`: Generated Qt Quick/C++ projects preserve the combined baseline:
  module file sets, scanning, standard headers, Qt policy, and nested adapter
  include paths.
- [ ] `BLD-015`: Generated Qt projects run the baseline presentation preflight
  for every QML registration header without treating it as a substitute for a
  full Qt build.
- [ ] `BLD-016`: The minimum Qt version and selected customizable Controls style
  are explicit and identical across application, lint, tests, screenshots, and
  packaging.
- [ ] `BLD-017`: QML module artifacts and runtime targets use separate output
  roots; identical executable and URI names are supported, and strict lint uses
  the configured QML root with minimum-version-compatible options.
- [ ] `TST-001`: Behavior changes have relevant tests.
- [ ] `TST-003`: Invalid, boundary, and failure paths are covered where relevant.
- [ ] `TST-006`: Zero discovered tests are not reported as success.
- [ ] `TST-007`: Tests cover every claimed surface, including presentation and
  QML/GUI smoke coverage for a Qt product.
- [ ] `TST-008`: Critical containment, non-overlap, breakpoint, repeated-size,
  and alignment invariants have deterministic QML checks where practical.
- [ ] `TST-009`: Strict `qmllint` allows zero project warnings and warning-fatal
  runtime tests instantiate popups, dialogs, delegates, editors, and responsive
  branches used by the primary flow.
- [ ] `TST-010`: The same-name target/URI fixture clean-configures, fully links,
  lints the generated module, loads `Main`, passes warning-fatal readiness
  smoke, and verifies `bin/` plus `qml/<URI>/` outputs when Qt is available.
- [ ] `VER-001`: Configure, build, and tests have separate results.
- [ ] `VER-003`: Exact commands and pass/fail counts are present.
- [ ] `VER-006`: Final diff and `git diff --check` were inspected.
- [ ] `VER-008`: Evidence names the exact enabled features and targets; no
  disabled or unbuilt surface inherits another target's `PASS`.
- [ ] `VER-009`: A clean full build, all tests, and product smoke checks passed
  before a generated archive was labeled final.
- [ ] `VER-010`: Exact visual-review viewport sizes, appearance modes, content
  states, screenshots, and interaction paths are recorded.
- [ ] `VER-011`: Qt version, effective Controls style, strict lint command and
  warning count, runtime command, and project-owned warning count are recorded.
- [ ] `VER-012`: The actual runtime target, `qmldir`, and `.qmltypes` paths are
  recorded after final linking; earlier generated-source success is not treated
  as a successful GUI build.

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
- [ ] `REP-010`: Qt reports name the style/version, lint result, runtime warning
  result, and interactions that instantiated lazy UI components.
- [ ] `REP-003`: Configure/build evidence is exact.
- [ ] `REP-004`: Test count and result are exact.
- [ ] `REP-005`: Known limitations are explicit.
- [ ] `REP-006`: Any exception is justified.
- [ ] `REP-007`: Reflected corrections explain the durable lesson.
- [ ] `REP-008`: Multi-surface products report an enabled/evidence/result matrix
  with `PASS`, `FAIL`, or `NOT VERIFIED` for every requested surface.
- [ ] `REP-009`: UI reports include the visual acceptance matrix and disclose
  any alignment, overflow, density, typography, contrast, or responsive limit.

## Inline Finding Shape

```text
[Priority] RULE-ID — Short title

Explain the concrete defect, the input or environment that triggers it, and the
smallest useful remediation. Keep the line range tight.
```

Do not manufacture findings to fill categories. A clean review may have no
actionable comments.
