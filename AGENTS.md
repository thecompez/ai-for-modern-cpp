# AGENTS.md

# Modern C++ Agent Knowledge Contract

This file is the canonical repository-wide instruction contract for AI coding
agents. Every agent must read it before planning, editing, reviewing, testing,
or releasing work in this repository.

The repository is not primarily an application or a generic project scaffold.
It is an executable reference that teaches AI agents how to reason about,
design, change, verify, and report work in a modern C++ repository. The source
code proves that the rules compile; the documentation explains the decisions;
the evals test whether an agent applies them correctly.

Primary references:

- ISO C++ Core Guidelines: https://isocpp.org/guidelines
- C++ Core Guidelines source: https://github.com/isocpp/CppCoreGuidelines
- C++ language status: https://isocpp.org/std/status
- CMake documentation: https://cmake.org/cmake/help/latest/

---

## 1. Normative Language And Authority

The words **MUST**, **MUST NOT**, **SHOULD**, **SHOULD NOT**, and **MAY** are
normative.

- **MUST / MUST NOT**: required for acceptance unless a higher-priority human
  instruction explicitly overrides the rule.
- **SHOULD / SHOULD NOT**: the default; deviations require a concrete reason.
- **MAY**: optional and context-dependent.

`AGENTS.md` is the canonical policy. Files under `docs/agent/` provide required
task-specific detail. If a detailed guide conflicts with this file, this file
wins and the conflict must be reported and corrected.

Rule identifiers are stable review handles. Agents should cite them when
explaining a decision or reporting a violation.

---

## 2. Repository Knowledge Model

- **KNO-001** — The repository MUST optimize for teaching reliable agent
  behavior, not accumulating unrelated product features.
- **KNO-002** — Production code MUST act as an executable proof of documented
  rules.
- **KNO-003** — Correct/incorrect examples MUST live in documentation unless
  they are expected to compile and are verified by the build.
- **KNO-004** — Repeated human corrections MUST be evaluated for promotion into
  a durable rule, review check, pattern, or eval scenario.
- **KNO-005** — Policy changes MUST update every affected knowledge surface:
  canonical rules, task guide, review checklist, examples, and evals.

### Project Initiation Gate

- **INI-001** — Before creating a new product, application, service, library,
  tool, repository, or implementing an idea, an agent MUST establish a
  human-approved project name. If the request does not provide an unambiguous
  name, the agent MUST ask for it as a blocking question and wait for the
  answer before writing code or creating project files.
- **INI-002** — While the project name is unresolved, an agent MUST NOT
  initialize a repository, generate an archive, create or edit production
  files, or invent CMake project names, target names, module prefixes, QML
  URIs, bundle identifiers, package identifiers, namespaces, or branding.
  Read-only discovery and requirements discussion MAY continue.
- **INI-003** — An explicit name in the request or an established name in an
  existing repository satisfies the gate. Agents MUST NOT ask again without a
  concrete naming conflict, and MUST NOT substitute placeholders such as
  `MyApp`, a feature description, or an invented marketing name for human
  approval.
- **INI-004** — When this repository is used as an external engineering
  authority, the agent MUST identify the exact repository revision it read and
  the routed guides it applied. A link or citation alone is not evidence that
  the current contract was loaded. If the required revision or guides cannot be
  read, implementation MUST stop and the limitation MUST be reported.

The knowledge architecture is described in
[`docs/agent/README.md`](docs/agent/README.md).

---

## 3. Task Routing

After reading this file, read only the guides required for the task.

| Task | Required guide |
|---|---|
| Start a new product, project, repository, or idea implementation | `docs/agent/START_PROJECT.md` before every other routed guide |
| Understand repository structure or introduce a subsystem | `docs/agent/ARCHITECTURE.md` |
| Add or change a C++ module | `docs/agent/MODULES.md`, `docs/agent/NAMING.md`, and `docs/agent/SYNTAX_AND_STYLE.md` |
| Write or review C++ syntax, identifiers, or formatting | `docs/agent/SYNTAX_AND_STYLE.md` and `docs/agent/NAMING.md` |
| Design or review a public API | `docs/agent/API_DESIGN.md` and `docs/agent/ERRORS_AND_RESOURCES.md` |
| Add ownership, handles, files, sockets, or threads | `docs/agent/ERRORS_AND_RESOURCES.md` |
| Add OS-specific behavior | `docs/agent/PLATFORM_BOUNDARIES.md` |
| Select the interface for an unspecified user-facing interactive application | `docs/agent/QT_QUICK_UI.md` and `docs/agent/ARCHITECTURE.md` |
| Design or implement a Qt graphical interface | `docs/agent/QT_QUICK_UI.md`, `docs/agent/ARCHITECTURE.md`, and `docs/agent/NAMING.md` |
| Generate a new Qt Quick/C++ project baseline | `docs/agent/PROJECT_CMAKE_BASELINE.md`, `docs/agent/QT_QUICK_UI.md`, and `docs/agent/CMAKE_AND_TOOLCHAINS.md` |
| Change CMake, compilers, modules, or standard-library integration | `docs/agent/CMAKE_AND_TOOLCHAINS.md` |
| Add or change behavior | `docs/agent/TESTING_AND_VERIFICATION.md` |
| Diagnose a known build or module failure | `docs/agent/COMMON_FAILURES.md` |
| Learn approved and forbidden code shapes | `docs/agent/PATTERNS.md` |
| Review a change | `docs/REVIEW.md` and all guides touched by the diff |
| Evaluate agent behavior | `evals/README.md` and the relevant scenario suite |

Do not load every detailed guide by default. Route by task, then read each
selected guide completely.

---

## 4. Required Agent Loop

Every implementation task MUST follow this loop:

```text
Read the request and applicable rules
Pass the project initiation gate when creating a new product or project
Inspect the current diff and working tree
Locate the owning subsystem and module boundary
Read the relevant implementation and tests
State important assumptions
Make the smallest correct change
Configure
Build
Run tests
Inspect failures
Fix and repeat verification
Review the final diff
Report exact evidence
```

- **SCP-001** — Agents MUST inspect before editing and MUST NOT guess project
  behavior.
- **SCP-002** — Agents MUST preserve unrelated human changes in a dirty working
  tree.
- **SCP-003** — Agents MUST make the smallest coherent change that fully solves
  the request.
- **SCP-004** — Broad rewrites, dependency additions, API renames, and formatting
  churn require explicit justification.
- **SCP-005** — Diagnosis does not authorize implementation unless the user also
  asks for a fix.
- **SCP-006** — No agent may claim success before collecting real verification
  evidence.

---

## 5. Architecture Rules

- **ARC-001** — Each behavior MUST have a clear owning subsystem.
- **ARC-002** — Dependencies SHOULD point from composition and adapters toward
  stable domain abstractions, not the reverse.
- **ARC-003** — Public interfaces MUST expose the smallest useful surface.
- **ARC-004** — Platform code, third-party adaptation, and low-level operations
  MUST remain at explicit boundaries.
- **ARC-005** — Vague dumping grounds such as `utils`, `helpers`, `common`, and
  `misc` MUST NOT be introduced without an existing domain-specific reason.
- **ARC-006** — New abstractions MUST solve a demonstrated design pressure; do
  not add speculative layers.
- **ARC-007** — Repository layout MUST communicate responsibility. New
  user-facing applications SHOULD separate domain, application, presentation,
  adapter, composition, and UI assets when those responsibilities exist; empty
  ceremonial layers and technology-named dumping grounds are forbidden.

See `docs/agent/ARCHITECTURE.md`.

---

## 6. Language And Module Rules

This repository targets C++20 or newer and uses C++26 for its executable
reference path. Prefer C++26, then C++23, with C++20 as the minimum family for
derived repositories.

- **MOD-001** — New internal production code MUST use C++ modules by default.
- **MOD-002** — Exported declarations MUST live in `.cppm` files.
- **MOD-003** — Non-trivial implementations MUST live in `.cpp` implementation
  units.
- **MOD-004** — Large algorithms, filesystem mutation, networking, database
  logic, UI behavior, and platform branches MUST NOT live in exported module
  interfaces.
- **MOD-005** — Lightweight templates, concepts, compile-time constants, small
  value types, and small `constexpr` functions MAY remain in `.cppm` when
  visibility is required.
- **MOD-006** — New `.h` files are forbidden unless an external tool or ABI
  requires that exact extension.
- **MOD-007** — `.hpp` is reserved for third-party, ABI, C API, or textual
  compatibility boundaries; it is not the default project architecture.
- **MOD-008** — Any header boundary MUST be isolated, documented, and kept out
  of domain logic.
- **MOD-009** — Project-owned production boundaries MUST use C++ modules.
  Standard-library integration MUST NOT cause a fallback to project headers or
  classic header/source architecture.
- **MOD-010** — Project code MUST NOT use the experimental `import std;` path.
  Standard-library declarations MUST come from the minimal owning standard
  headers while project-owned `.cppm` modules, module imports, and CMake module
  file sets remain intact.
- **MOD-011** — In a module unit, standard-library headers MUST appear
  in the global module fragment after `module;` and before the named module
  declaration. They MUST NOT be textually included inside the named module
  purview.
- **MOD-012** — Standard-library headers do not authorize new project-owned
  `.h` or `.hpp` files. Standard headers and project headers are distinct
  architectural concerns.

Preferred layout:

```text
src/
  project/
    project.cppm
    project.cpp
    project_platform.cppm
    project_platform_macos.cpp
    project_platform_windows.cpp
    project_platform_linux.cpp
```

See `docs/agent/MODULES.md`.

---

## 7. Naming Rules

- **NAM-001** — Module names MUST be dotted, lowercase, stable,
  domain-oriented, and contain no underscore.
- **NAM-002** — Namespaces MUST mirror module identity.
- **NAM-003** — Types, classes, concepts, and enum-class enumerators MUST use
  PascalCase.
- **NAM-004** — Functions, parameters, and local variables MUST use
  lowerCamelCase.
- **NAM-005** — Private and protected non-static data members MUST use the
  `m_` prefix followed by lowerCamelCase.
- **NAM-006** — Identifiers ending in `_` are forbidden for project-owned data
  members.
- **NAM-007** — Reserved identifiers and keyword workarounds such as `delete_`,
  `class_`, `_Name`, and `__name` MUST NOT be introduced.
- **NAM-008** — File names MAY use underscores when useful; the module identity
  inside the source remains dotted.
- **NAM-009** — Multiword identifiers MUST preserve word boundaries through the
  required casing; do not collapse `expressionText` into `expressiontext`.
- **NAM-010** — Acronyms MUST be treated as words: use `HttpClient`, `UserId`,
  and `parseJson`, not `HTTPClient`, `UserID`, or `parseJSON`.
- **NAM-011** — Boolean names SHOULD read as predicates, such as `isReady`,
  `hasValue`, `canRetry`, or `shouldClose`.
- **NAM-012** — QML types and files MUST use PascalCase; QML `id` values,
  properties, signals, handlers, and JavaScript functions MUST use lowerCamelCase.

Correct:

```cpp
export module modern.cpp.agent;

export namespace modern::cpp::agent {
enum class StandardLevel { Cpp20, Cpp23, Cpp26 };

class Expression final {
private:
    std::string m_expressionText;
};
}
```

Incorrect:

```cpp
enum class ErrorCode { empty_expression };

class Expression final {
private:
    std::string my_member;
    std::string mymember_;
};
```

See `docs/agent/NAMING.md`.

---

## 8. Syntax And Style Rules

Modern syntax is a correctness and readability contract, not optional polish.

- **SYN-001** — Function return syntax MUST optimize readability rather than
  enforce one mechanical form. Leading return types SHOULD be used for simple,
  immediately recognizable results such as `void`, `bool`, numeric types, and
  short domain types. Trailing return types SHOULD be used when required by the
  language or when they materially improve a dependent, complex, or multiline
  declaration.
- **SYN-002** — Variables MUST be initialized at declaration; default member
  initializers SHOULD establish safe object state.
- **SYN-003** — Use `const`, `constexpr`, `consteval`, and `constinit` whenever
  their guarantees accurately express the intended lifetime and mutability.
- **SYN-004** — Enumerations MUST use `enum class`; enumerator cases MUST follow
  `NAM-003`, including in every `switch` label.
- **SYN-005** — Use `nullptr`, never `NULL` or integer zero as a null pointer.
- **SYN-006** — C-style and functional-style casts are forbidden; use the
  narrowest named C++ cast and justify `reinterpret_cast`.
- **SYN-007** — Single-argument constructors MUST be `explicit` unless implicit
  conversion is the documented purpose of the type.
- **SYN-008** — Results whose loss can hide an error or skip required work MUST
  be marked `[[nodiscard]]`.
- **SYN-009** — Overriding virtual functions MUST use `override`; types and
  functions that are intentionally not extensible SHOULD use `final`.
- **SYN-010** — Prefer brace initialization when it prevents narrowing or
  establishes an explicit initial state.
- **SYN-011** — Macros MUST NOT implement constants, types, functions, or
  business logic when a language feature can express the same intent.
- **SYN-012** — Declare one logical object per statement and avoid hidden
  mutation, comma expressions, and dense clever expressions.
- **SYN-013** — `using namespace` is forbidden at namespace scope in project
  code; narrow function-local usage MAY be accepted when unambiguous.
- **SYN-014** — Use `noexcept` only when the contract can be upheld; destructors
  and move operations SHOULD state the guarantee when it affects generic code.
- **SYN-015** — Braces are required for control-flow bodies, including
  single-statement branches and loops.
- **SYN-016** — Class declarations SHOULD order access sections as `public`,
  `protected`, then `private`; behavior precedes data, and invariant-bearing
  data MUST remain private.
- **SYN-017** — Use `using` aliases instead of `typedef` for project-owned type
  aliases.
- **SYN-018** — Constructor initializer lists MUST follow data-member declaration
  order and MUST NOT perform hidden unrelated work.
- **SYN-019** — Lambda captures MUST make lifetime intent clear; stored or
  asynchronous lambdas MUST NOT capture short-lived objects by reference.
- **SYN-020** — `auto` SHOULD remove repetition without hiding important domain,
  ownership, or conversion semantics.
- **SYN-021** — Prefer range-based loops and standard range algorithms when they
  express iteration more directly without weakening clarity or portability.
- **SYN-022** — Source units SHOULD follow a stable reading order: module
  declaration/imports, namespace, public or member definitions, private helpers,
  then the smallest composition entry point where applicable.
- **SYN-023** — New project-owned formatted console output MUST use
  `std::print` or `std::println`. Stream insertion with `std::cout`,
  `std::cerr`, or `std::clog` is forbidden for ordinary output; a stream-only
  compatibility boundary requires an explicit local justification.

Correct:

```cpp
void inputDecimalPoint();

[[nodiscard]] auto parseExpression(std::string_view text)
    -> std::expected<Expression, ErrorCode>;

std::println("Result: {}", result);

switch (errorCode) {
case ErrorCode::EmptyExpression:
    return "Expression must not be empty.";
case ErrorCode::InvalidToken:
    return "Expression contains an invalid token.";
}
```

See `docs/agent/SYNTAX_AND_STYLE.md`.

---

## 9. API And Compile-Time Rules

- **API-001** — Every exported class, function, enum, concept, and public data
  structure MUST have English Doxygen documentation.
- **API-002** — Public APIs MUST communicate ownership, lifetime, optionality,
  and failure explicitly.
- **API-003** — Use `std::span` for non-owning contiguous views and
  `std::string_view` for read-only strings only when lifetime is clear.
- **API-004** — Use `std::optional` for optional values and `std::variant` for
  closed alternatives.
- **API-005** — Generic public APIs MUST use meaningful concepts when an
  operation set or type category affects correctness.
- **API-006** — Prefer compile-time enforcement when the rule is knowable at
  compile time and produces a useful diagnostic.
- **API-007** — Concepts MUST express real contracts and MUST NOT be decorative.
- **API-008** — Use `constexpr`, `consteval`, `constinit`, ranges, and coroutines
  only when they improve correctness or clarity.

See `docs/agent/API_DESIGN.md`.

---

## 10. Error And Resource Rules

- **ERR-001** — Recoverable expected failures SHOULD use `std::expected` or the
  project equivalent.
- **ERR-002** — Exceptions MAY represent construction failure, violated
  invariants, or genuinely exceptional subsystem failures.
- **ERR-003** — Exceptions MUST NOT be ordinary control flow for expected
  outcomes unless the owning subsystem explicitly establishes that policy.
- **ERR-004** — Errors MUST NOT be swallowed, converted into fake success, or
  reduced to an unexplained `bool`.
- **ERR-005** — Logging and continuing is allowed only when continuation is
  demonstrably safe.
- **RES-001** — Every acquired resource MUST have deterministic RAII ownership.
- **RES-002** — Raw owning pointers and scattered manual cleanup are forbidden.
- **RES-003** — `new` and `delete` MAY appear only inside an isolated low-level
  ownership abstraction with tests and justification.
- **RES-004** — Move-only resource owners MUST make copy and move semantics
  explicit.
- **RES-005** — Files, sockets, handles, locks, threads, timers, and temporary
  directories are resources and follow the same ownership rules.

See `docs/agent/ERRORS_AND_RESOURCES.md`.

---

## 11. Platform Boundary Rules

- **PLT-001** — Platform macros MAY appear only at platform boundaries.
- **PLT-002** — Business and domain logic MUST NOT contain scattered platform
  conditionals.
- **PLT-003** — Each supported platform SHOULD have a separate implementation
  unit behind a stable module declaration.
- **PLT-004** — OS handles and C APIs MUST be wrapped behind small RAII-safe
  adapters.
- **PLT-005** — Unsupported platforms MUST fail explicitly, not silently select
  unrelated behavior.

See `docs/agent/PLATFORM_BOUNDARIES.md`.

---

## 12. Qt Quick UI Rules

These rules apply when a derived project requires a Qt graphical interface or
when `GUI-015` selects one for an otherwise unspecified user-facing interactive
application. They do not add Qt as a dependency of this executable knowledge
reference.

- **GUI-001** — New Qt graphical interfaces MUST use Qt 6, Qt Quick, QML, and
  Qt Quick Controls. Qt Widgets is not the default UI technology.
- **GUI-002** — New use of Qt Widgets is forbidden unless the user explicitly
  requests it or an existing compatibility boundary requires it; the exception
  MUST be documented.
- **GUI-003** — Domain and application behavior MUST remain in C++ modules and
  MUST NOT depend on QML or visual controls.
- **GUI-004** — QML MUST own presentation, layout, animation, and interaction;
  business rules, validation, persistence, and authoritative state MUST NOT be
  implemented in QML JavaScript.
- **GUI-005** — The QML/C++ boundary MUST expose a small presentation contract
  through typed properties, invokable operations, signals, and purpose-built
  models or view models.
- **GUI-006** — Qt meta-object or MOC compatibility headers MAY use `.hpp` only
  as an isolated adapter under `MOD-007`; they MUST NOT become domain headers.
- **GUI-007** — Before implementation, an agent MUST define user flows, screen
  states, reusable components, design tokens, and failure/empty/loading states.
- **GUI-008** — Layouts MUST be responsive and adaptive; hard-coded positioning
  for a single window size is forbidden unless the interface is intentionally
  fixed and that constraint is documented.
- **GUI-009** — Interactive controls MUST support keyboard navigation, visible
  focus, accessible names, and sufficient contrast.
- **GUI-010** — User-visible text MUST be translation-ready; colors, spacing,
  typography, and motion SHOULD come from reusable design tokens.
- **GUI-011** — Long-running work MUST NOT block the GUI thread; cancellation,
  progress, failure, and lifetime MUST be modeled explicitly.
- **GUI-012** — QML modules MUST be registered with `qt_add_qml_module` and
  targets MUST link only the required Qt Quick components.
- **GUI-013** — Qt UI changes MUST test C++ presentation behavior and SHOULD add
  QML interaction tests, linting, or smoke coverage where the toolchain permits.
- **GUI-014** — QObject parent ownership, QML engine ownership, and RAII
  ownership MUST be deliberate and MUST NOT produce ambiguous lifetime.
- **GUI-015** — For a user-facing interactive application, when the interface
  type is unspecified and the context does not clearly identify a CLI tool,
  service, library, daemon, or other headless product, an agent MUST NOT deliver
  a CLI-only application. The primary interface MUST use Qt 6, Qt Quick, QML,
  and Qt Quick Controls.
- **GUI-016** — A CLI MAY be provided as a secondary adapter for automation,
  testing, or headless use. It MUST depend on the same application and domain
  modules as the graphical interface and MUST NOT duplicate business logic or
  replace the required primary interface.
- **GUI-017** — A new or redesigned interface MUST define a product-specific
  visual and interaction direction grounded in the audience, primary tasks,
  information hierarchy, affordances, feedback, error prevention, and recovery.
  Agents MUST NOT reuse a generic repetitive screen recipe or copy reference
  visuals without adapting them to the product.
- **GUI-018** — New Qt Quick repositories MUST place QML and visual assets under
  a top-level `ui/` boundary. Pages, reusable components, theme tokens, and
  assets SHOULD use responsibility-based subdirectories when they exist; a
  top-level `qml/` dumping directory is not the preferred project structure.
- **GUI-019** — When a QML module contains files in extra directories, projects
  that support Qt policy `QTP0004` MUST select its `NEW` behavior before
  `qt_add_qml_module`. The policy check MUST remain compatible with the declared
  minimum Qt version. Missing generated `.qmltypes` after a failed CMake
  Generate step is a cascading symptom, not an independent root cause.
- **GUI-020** — Every project-owned header referenced by Qt-generated QML type
  registration code MUST be reachable through a target-local include directory.
  A `QML_ELEMENT` adapter stored under `src/presentation/` MUST add that
  directory to the QML target; agents MUST NOT edit generated
  `*_qmltyperegistrations.cpp` files or move adapters into the repository root
  merely to satisfy generated includes.
- **GUI-021** — A QObject exposed as a QML-creatable type MUST NOT be `final`.
  Qt's generated registration wrapper derives from such a type. A presentation
  adapter MAY be `final` only when QML does not construct it and its explicit
  registration and ownership strategy does not require subclassing.
- **GUI-022** — A requested or default Qt graphical deliverable MUST complete at
  least one clean Qt-enabled configure and full build before it is described as
  complete. The build MUST compile generated MOC, QML type-registration,
  resource, and QML cache sources and link the graphical executable. A core-only
  or GUI-disabled build is partial evidence and MUST NOT validate the GUI.
- **GUI-023** — Before implementing a screen, agents MUST define a layout
  contract: outer content bounds, columns, alignment lines, margins, gutters,
  spacing scale, repeated-control metrics, minimum and maximum content widths,
  and each region's grow, shrink, wrap, or overflow behavior. Coincidental
  alignment from unrelated hard-coded values is not acceptable.
- **GUI-024** — Repeated controls and parallel regions MUST preserve deliberate
  edge, center, baseline, size, and gap relationships. Header actions, content
  edges, grids, displays, footers, and adjacent panels MUST share documented
  alignment anchors or have an explicit reason not to.
- **GUI-025** — Responsive design MUST define compact, standard, and wide
  compositions. Expanding a window MUST NOT merely stretch containers while
  leaving task controls pinned to one edge, producing accidental dead space, or
  separating related content. Use bounded task widths, centering, reflow, or
  deliberate redistribution according to the product hierarchy.
- **GUI-026** — A graphical deliverable MUST pass a visual-detail review from
  rendered screenshots at representative minimum, standard, and wide sizes and
  in relevant appearance and content states. The review MUST inspect clipping,
  overlap, truncation, alignment, baselines, spacing rhythm, optical centering,
  contrast, focus, hit targets, and unintended empty space. Code inspection or
  successful compilation alone cannot justify a polished or final UI claim.
- **GUI-027** — Every QML type, property, signal, method, enum, attached
  property, and import MUST exist on the exact instantiated type in the
  project's declared minimum Qt version. Agents MUST NOT infer API availability
  from a visually similar type or from a newer Qt release. The complete QML
  module MUST pass `qmllint` and runtime component creation before delivery.
- **GUI-028** — A Qt Quick Controls styling strategy MUST be explicit and
  consistent. A project that replaces `background`, `contentItem`, `indicator`,
  delegates, or popups MUST select a customizable style such as Basic, Fusion,
  Imagine, Material, or Universal before any Controls QML is loaded. A project
  that intentionally uses a native style MUST keep to that style's supported
  customization surface. Platform-default style selection is not an acceptable
  hidden dependency for custom controls.
- **GUI-029** — QML geometry MUST have one acyclic ownership direction.
  `implicitWidth` or `implicitHeight` MUST NOT depend on a parent viewport's
  available size when that viewport derives its own implicit or content size
  from the child. Scrollable editors, popups, delegates, and layouts MUST define
  which object owns viewport size and which owns content size, and runtime
  binding-loop warnings are release-blocking defects.
- **GUI-030** — Control geometry MUST be content-safe. Primary and destructive
  action labels MUST remain fully readable in the reference locale; translated
  text MUST reflow, grow, or use an explicitly reviewed alternate label rather
  than accidental elision. Popup delegates, bilingual or RTL rows, icons,
  indicators, focus rings, and hit targets MUST remain contained and aligned at
  supported sizes. Fixed widths require evidence against realistic longest
  content.
- **GUI-031** — Typography MUST be portable and intentional. A font family MAY
  be named only when it is bundled with a documented license or verified on
  every supported platform with a fallback. Otherwise use Qt/system-resolved
  fonts and style hints. Missing-font substitutions, inconsistent metrics, and
  avoidable font-alias warnings MUST be fixed before delivery.
- **GUI-032** — Qt UI verification MUST be warning-clean for project-owned QML.
  Strict QML lint and a deterministic runtime smoke or interaction test MUST
  fail on component-load errors, unsupported control customization, binding
  loops, invalid properties, missing project fonts, and other project-caused Qt
  warnings. The smoke path MUST reach an explicit ready state and exercise the
  primary flow; merely starting the event loop for a fixed delay is
  insufficient.

See `docs/agent/QT_QUICK_UI.md`.

---

## 13. CMake And Toolchain Rules

Primary path:

```text
Clang 22+ or GCC 15+
CMake 3.30+
Ninja 1.11+
C++26
project-owned C++ modules
standard-library headers in global module fragments
```

- **BLD-001** — Use target-based modern CMake.
- **BLD-002** — New module interfaces MUST be declared through
  `target_sources(... FILE_SET CXX_MODULES ...)`.
- **BLD-003** — Use target-local compile features, definitions, include paths,
  and options; do not mutate global compiler flags casually.
- **BLD-004** — `CXX_SCAN_FOR_MODULES` MUST be enabled for targets that produce
  or consume project-owned modules. `CMAKE_CXX_MODULE_STD` is not part of the
  supported build path.
- **BLD-005** — CMake MUST NOT probe, enable, or configure experimental
  standard-library modules. `CMAKE_CXX_COMPILER_IMPORT_STD`,
  `CMAKE_CXX_STDLIB_MODULES_JSON`, and experimental import-std gates MUST NOT
  influence project configuration.
- **BLD-006** — Compiler, CMake, generator, selected language standard, and
  project-module dependency scanning form one compatibility unit and MUST be
  diagnosed together.
- **BLD-007** — Unsupported toolchains MUST fail at configure time with the
  observed values and a useful remediation direction.
- **BLD-008** — Agents MUST NOT silently downgrade the language standard or
  project-owned module architecture to obtain a green build. Standard-library
  headers in a global module fragment are the primary architecture, not a
  downgrade or fallback.
- **BLD-009** — Import-std UUID gates, standard-library module metadata repair,
  and conditional standard-library modes are forbidden. Generated projects
  MUST use one deterministic standard-header path.
- **BLD-010** — CMake 3.30+ with Ninja and a compiler that supports the selected
  language standard MAY build project-owned modules without standard-library
  module metadata. Diagnostics MUST discuss project-module scanning rather than
  recommend a newer CMake solely for `import std`.
- **BLD-011** — Builds MUST NOT locate, validate, rewrite, or cache
  `libc++.modules.json` or `libstdc++.modules.json`. Those files are outside the
  supported standard-header architecture.
- **BLD-012** — A newer compiler major version is not automatically supported.
  Each compiler/CMake/generator combination MUST pass configure, build, and
  tests before becoming a supported project-module toolchain.
- **BLD-013** — Standard-library integration MUST have one mode: minimal
  standard headers. Build options and compile definitions that switch between
  standard-library delivery mechanisms are forbidden.
- **BLD-014** — Generated Qt Quick/C++ projects MUST begin from
  `docs/agent/PROJECT_CMAKE_BASELINE.md`. The baseline MUST register `.cppm`
  files through `FILE_SET CXX_MODULES`, enable target-local module scanning,
  use standard headers, guard required Qt policies, and expose nested
  presentation headers to generated QML registration code.
- **BLD-015** — Generated Qt Quick projects MUST copy and run the baseline's
  deterministic presentation preflight against every project-owned QML
  registration header. A `QML_ELEMENT` type declared `final` MUST fail during
  configure with a causal diagnostic. The preflight supplements and MUST NOT
  replace the full Qt build required by `GUI-022`.
- **BLD-016** — Generated Qt Quick projects that customize Controls MUST select
  one supported customizable style in the composition root before loading QML,
  and MUST use that same effective style for application runs, QML tests, lint
  setup, screenshots, and smoke verification. The selected style and minimum Qt
  version are build-and-test inputs, not undocumented workstation defaults.

Do not use `std::views::enumerate` in portable examples unless the active
standard library has been verified to provide it.

See `docs/agent/CMAKE_AND_TOOLCHAINS.md`.

---

## 14. Testing And Verification Rules

- **TST-001** — Every behavior change MUST have relevant automated coverage
  when practical.
- **TST-002** — Tests SHOULD exercise public behavior rather than private
  implementation details.
- **TST-003** — Recoverable failures, invalid input, boundary values, and
  ownership behavior MUST be tested when introduced.
- **TST-004** — Tests MUST be deterministic and independent of external network
  or mutable global state unless explicitly classified as integration tests.
- **TST-005** — Temporary resources MUST use RAII cleanup.
- **TST-006** — A test command that discovers zero tests MUST NOT be reported as
  a successful test run.
- **TST-007** — Verification depth MUST cover every claimed product surface.
  For a Qt application this includes domain/application behavior, presentation
  behavior, QML creation or interaction smoke coverage, and the complete Qt
  integration build; a headless unit-test target alone is insufficient.
- **TST-008** — Critical responsive and geometry invariants SHOULD have
  deterministic QML tests where practical, including parent containment,
  non-overlap, breakpoint selection, repeated-control sizing, and primary
  alignment anchors. Automated geometry checks supplement rather than replace
  rendered visual review.
- **TST-009** — Qt Quick projects MUST run strict QML lint with a zero
  project-warning budget and a warning-fatal runtime test under the selected
  Controls style. Tests MUST cover component creation plus enough interaction
  and representative content to instantiate lazy popups, dialogs, delegates,
  scrollable editors, and other primary-path components.
- **VER-001** — Configure, build, and test are separate results and MUST be
  reported separately.
- **VER-002** — Agents MUST stop a command chain after configure failure; later
  missing-build and zero-test messages are cascading symptoms.
- **VER-003** — Exact commands and exact pass/fail counts MUST be reported.
- **VER-004** — Warnings introduced by the change MUST be resolved.
- **VER-005** — Upstream experimental warnings MAY remain only when identified
  accurately and not caused by project code.
- **VER-006** — `git diff --check` and final-diff inspection are required before
  completion.
- **VER-007** — Documentation and agent-rule changes MUST run the knowledge
  contract test in addition to the normal build and tests.
- **VER-008** — Verification claims MUST match the exact configured feature set
  and targets that ran. Disabled, dependency-skipped, unavailable, or unbuilt
  deliverables MUST be reported as `NOT VERIFIED`, never inferred from another
  target's success.
- **VER-009** — Before delivering a generated project archive or calling it
  ready, an agent MUST use a clean build tree to configure all requested default
  features, build the full default target, run all discovered tests with zero
  tests treated as an error, and run applicable product smoke checks. If the
  required SDK or runtime is unavailable, the artifact MAY be labeled a draft
  but MUST NOT be presented as a verified final deliverable.
- **VER-010** — Final Qt verification MUST record the exact viewport sizes,
  appearance modes, content states, screenshots, and interaction paths that
  were visually inspected. Any unreviewed required state is `NOT VERIFIED`.
- **VER-011** — Final Qt evidence MUST name the minimum Qt version, effective
  Controls style, strict `qmllint` command and warning count, runtime smoke or
  interaction command, and project-owned Qt/QML warning count. A clean compile
  with runtime warnings is not a clean Qt verification result.

Preferred loop:

```bash
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build --parallel
ctest --test-dir build --output-on-failure --no-tests=error
```

See `docs/agent/TESTING_AND_VERIFICATION.md`.

---

## 15. Documentation And Knowledge Rules

- **DOC-001** — Source comments and repository technical documentation MUST be
  written in English.
- **DOC-002** — Documentation MUST explain decisions, boundaries, and failure
  modes rather than restating syntax.
- **DOC-003** — Good and bad examples MUST be labeled unambiguously.
- **DOC-004** — Bad examples MUST NOT be added as normal build inputs.
- **DOC-005** — Architecture diagrams MUST match the current dependency graph.
- **DOC-006** — A rule should be short, testable, general, and owned by one
  canonical location.
- **DOC-007** — Task guides MAY elaborate a rule but MUST NOT redefine it.
- **DOC-008** — Canonical guides and general-purpose examples MUST use
  domain-neutral placeholder names unless a concrete domain is the behavior
  being taught. Scenario-specific evals MAY use concrete domains.

---

## 16. Security And Tool Rules

- **SEC-001** — Secrets, tokens, private endpoints, and machine-specific paths
  MUST NOT be committed.
- **SEC-002** — Local active MCP configuration belongs in `.mcp.json` and MUST
  remain ignored.
- **SEC-003** — Prefer the smallest useful permission set: read-only context,
  local git, remote read access, build/test tools, then write capability only
  with explicit intent.
- **SEC-004** — Deployment, payment, production database, destructive, or broad
  write tools require explicit user authorization.
- **SEC-005** — Destructive operations require exact targets and prior
  read-only resolution.
- **SEC-006** — External dependencies require a strong reason and a documented
  ownership/update strategy.

See `docs/MCP.md` for the MCP safety model.

---

## 17. Change, Commit, And Release Rules

- **CHG-001** — Commits MUST be cohesive and use precise imperative titles.
- **CHG-002** — Pull request summaries MUST state what changed, why, how it was
  tested, known limitations, and intentional exceptions.
- **CHG-003** — Tags, releases, deployments, and publishing require explicit
  human approval.
- **CHG-004** — Agents MUST NOT stage, commit, push, or open a pull request
  unless the user requested that workflow.

Good commit titles:

```text
Add module-based version parser
Fix platform app data directory resolution
Define agent eval scenarios for module changes
```

Bad commit titles:

```text
Update code
Fix stuff
AI changes
```

---

## 18. Final Report Contract

Every completed implementation report MUST include:

- **REP-001** — Files changed.
- **REP-002** — What changed and why.
- **REP-003** — Configure and build commands with exact results.
- **REP-004** — Test commands, discovered test count, and exact results.
- **REP-005** — Known limitations or unverified environments.
- **REP-006** — Any rule exception and its justification.
- **REP-007** — For reflected corrections, what was learned and why the new
  rule is general enough to keep.
- **REP-008** — Reports for multi-surface products MUST include a verification
  matrix that names each requested surface or deliverable, whether it was
  enabled, the exact target or test that exercised it, and its `PASS`, `FAIL`,
  or `NOT VERIFIED` result.
- **REP-009** — UI reports MUST list the visual acceptance matrix and any known
  alignment, overflow, density, typography, contrast, or responsive limitation;
  a generic statement such as "responsive and polished" is not evidence.
- **REP-010** — Qt UI reports MUST record the effective Controls style, Qt
  version, QML lint result, runtime warning result, and the interactions that
  instantiated popups, dialogs, delegates, editors, and other lazy components.

Never report:

```text
It should work.
Probably fixed.
Tests should pass.
```

Report only observed evidence.

---

## 19. Forbidden Agent Behavior

Agents MUST NOT:

- Invent build, test, review, or tool results.
- Hide failures or present cascading errors as independent root causes.
- Replace modules with classic include architecture.
- Treat standard-library headers as permission to replace `.cppm`
  modules or create project-owned headers.
- Use `import std;`, experimental import-std CMake gates, or standard-library
  module metadata in project code or generated build files.
- Place standard-library headers inside a named module purview rather
  than its global module fragment.
- Add legacy project headers without a justified boundary.
- Add raw ownership, manual cleanup, or global mutable state casually.
- Scatter platform macros through domain logic.
- Change public API names or unrelated subsystems without need.
- Perform broad formatting-only rewrites during functional work.
- Add non-English source comments.
- Introduce lowercase or snake_case enum-class enumerators.
- Introduce trailing-underscore or unprefixed private data members.
- Mechanically rewrite every function into trailing-return syntax when a
  leading return type is clearer.
- Use iostream insertion for ordinary formatted console output when
  `std::print` or `std::println` expresses the operation.
- Choose Qt Widgets for a new Qt UI without an explicit, documented exception.
- Silently reduce an unspecified user-facing interactive application to a
  CLI-only deliverable.
- Put authoritative domain or application behavior in QML JavaScript.
- Produce a generic repetitive UI without a product-specific hierarchy,
  interaction rationale, or verified UX states.
- Mark a QML-creatable QObject `final` while relying on Qt's generated type
  registration to construct it.
- Claim that a Qt application is complete because only its core library, CLI,
  or headless tests built while the graphical target was disabled or unbuilt.
- Deliver a generated project as final when any requested primary surface is
  `NOT VERIFIED` because its SDK, runtime, build target, or smoke test was not
  available.
- Claim a UI is polished or responsive without rendered inspection at minimum,
  standard, and wide sizes and representative content states.
- Accept accidental dead space, drifting alignment lines, clipped peripheral
  controls, inconsistent repeated metrics, or edge-pinned task content merely
  because the QML uses layout containers.
- Customize Qt Quick Controls while silently inheriting a native platform style
  that rejects custom `background`, `contentItem`, `indicator`, delegate, or
  popup implementations.
- Use a QML property because a similar visual type exposes it, without verifying
  the exact instantiated type and declared minimum Qt version.
- Accept QML binding loops, missing-font substitution, unsupported-style
  customization, component-load errors, clipped popup rows, or elided primary
  actions because the executable still opens.
- Treat a timer-only GUI launch as proof that lazy controls and the primary
  interaction path are warning-free.
- Create a top-level `qml/` dumping directory for a new Qt Quick repository
  instead of an explicit `ui/` boundary.
- Edit generated QML type registration files or omit target-local include paths
  for nested `QML_ELEMENT` presentation adapters.
- Treat the executable example as permission to accumulate unrelated showcase
  features.
- Turn human corrections into noisy one-off rules; generalize only durable
  lessons.

---

## 20. Multi-Agent Compatibility

For Claude Code:

- `CLAUDE.md` MUST point to this file.
- `.claude/commands/` workflows MUST preserve verification requirements.

For Codex:

- Repository-local skills under `.agents/skills/` MUST route back to this file
  and the applicable task guides.
- Expected file layout and commands MUST be explicit.

For GitHub Copilot and other agents:

- Public APIs, rule identifiers, module names, and examples MUST remain
  unambiguous and searchable.

All agent-specific workflows are adapters. `AGENTS.md` remains the source of
truth.
