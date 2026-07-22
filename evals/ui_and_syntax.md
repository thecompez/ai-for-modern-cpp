# Qt Quick UI And Syntax Scenarios

## EVAL-UI-001 — Unspecified Qt Calculator Technology

**Prompt**

```text
Create a graphical calculator with Qt.
```

**Required behavior**

- Select Qt 6, Qt Quick, QML, and Qt Quick Controls.
- Define interaction states, component boundaries, keyboard behavior, and
  design tokens before generating screens.
- Keep arithmetic, parsing, and validation in C++ modules.
- Use a small C++ presentation adapter for the QML boundary.
- Register QML with `qt_add_qml_module` and add relevant tests.

**Forbidden behavior**

- Selecting Qt Widgets because the prompt only says Qt.
- Putting calculator evaluation in QML JavaScript.
- Building a fixed screenshot with hard-coded positions.

**Rule coverage**: `GUI-001` through `GUI-013`, `ARC-002`, `MOD-001`.

## EVAL-UI-002 — Explicit Widgets Compatibility Request

**Prompt**

```text
Extend an existing Qt Widgets medical device interface. Rewriting it is outside
the certified change scope.
```

**Required behavior**

- Recognize an explicit compatibility boundary under `GUI-002`.
- Preserve the existing technology and document why Qt Quick is not introduced.
- Keep the change scoped and apply all applicable C++, naming, safety, and test
  rules.

**Forbidden behavior**

- Rewriting the certified UI in QML without authorization.
- Claiming that Qt Widgets is generally preferred for new interfaces.

## EVAL-UI-003 — Business Logic In QML

**Diff under review**

```qml
Button {
    onClicked: result = parseFloat(left.text) / parseFloat(right.text)
}
```

**Expected findings**

- `GUI-003` and `GUI-004`: authoritative parsing, arithmetic, and error handling
  belong in C++ domain/application modules.
- `ERR-001`: invalid numbers and division by zero require explicit errors.
- `GUI-005`: QML should forward an intent to a typed presentation contract.

## EVAL-UI-004 — Pretty But Incomplete UI

**Claim under review**

```text
The interface is polished because it matches the screenshot at 1280x720.
Keyboard focus, accessibility, translation, errors, and resizing were not tested.
```

**Expected findings**

The interface is incomplete under `GUI-007` through `GUI-010` and `GUI-013`.
The reviewer requests exact evidence for states, resizing, keyboard flow,
accessible naming, contrast, and translation-ready text.

## EVAL-UI-005 — Unspecified Interactive Application Surface

**Prompt**

```text
Build a small user-facing application that accepts values, performs an
operation, and keeps a visible history. Follow this repository's engineering
rules.
```

**Required behavior**

- Recognize a user-facing interactive product whose interface is unspecified.
- Select Qt 6, Qt Quick, QML, and Qt Quick Controls as the primary interface.
- Keep authoritative behavior in shared C++ application and domain modules.
- Add a CLI only when automation, testing, or headless use justifies it.
- When a CLI is added, keep it thin and connect both adapters to the shared core.
- Build and test the actual Qt Quick target before claiming completion.

**Forbidden behavior**

- Delivering only a command-line program because it is the smallest executable.
- Treating an optional CLI as a replacement for the primary interface.
- Duplicating validation or business behavior in QML and CLI parsing.
- Adding Qt to a request explicitly scoped to a CLI, service, library, daemon,
  or headless process.

**Rule coverage**: `GUI-001`, `GUI-003` through `GUI-005`, `GUI-012`,
`GUI-015`, `GUI-016`, `ARC-002`, `SCP-003`, and `VER-001`.

## EVAL-UI-006 — Generic Repetitive AI Interface

**Proposal under review**

```text
Use the same centered title, gradient background, glass panel, and grid of
rounded cards used in the last three generated applications. Start coding
before defining the audience, hierarchy, states, or recovery flow.
```

**Expected findings**

- `GUI-017`: define the audience, primary task, information hierarchy,
  affordances, feedback, error prevention/recovery, and product-specific visual
  direction before choosing components.
- Reusable tokens may provide consistency, but screen composition must follow
  the task and content density rather than repeat one decorative recipe.
- Verify the main flow at representative sizes and states; visual novelty alone
  is not evidence of usable UX.

## EVAL-UI-007 — Technology-Named QML Bucket

**Proposed new repository layout**

```text
src/
  main.cpp
qml/
  Main.qml
  EverythingElse.qml
```

**Expected findings**

- `ARC-007`: identify domain, application, presentation, adapter, and
  composition responsibilities that actually exist.
- `GUI-018`: place QML, theme tokens, and visual assets under `ui/`, with
  responsibility-based `pages/`, `components/`, `theme/`, or `assets/`
  subdivisions only when justified.
- Do not create empty layers merely to imitate the reference layout.

## EVAL-UI-008 — QML Policy Warning After Failed Generate

**Observed IDE output**

```text
Qt policy QTP0004 is not set for extra directories containing QML files.
CMake Generate step failed.
MyApp.qmltypes does not exist.
```

**Required behavior**

- Treat the CMake Generate failure as causal and the missing generated
  `.qmltypes` file as a cascading IDE symptom.
- Fix the first Generate failure and regenerate before diagnosing QML type
  registration.
- When the QML module has extra directories, select QTP0004 `NEW` before
  `qt_add_qml_module`.
- Guard the policy with `QT_KNOWN_POLICY_QTP0004` when the declared minimum Qt
  version may predate the policy; do not raise the minimum solely to silence a
  warning.

**Rule coverage**: `GUI-012`, `GUI-019`, `VER-001`, `VER-002`.

## EVAL-UI-009 — Nested QML Element Header Is Not Found

**Observed build output**

```text
generated/MyApp_qmltyperegistrations.cpp: use of undeclared identifier
'AppViewModel'
```

The adapter is listed under `SOURCES` but lives at
`src/presentation/app_view_model.hpp`.

**Required behavior**

- Inspect the generated source and recognize its basename include.
- Add `src/presentation` to the QML target with
  `target_include_directories(... PRIVATE ...)`.
- Keep the adapter nested at the presentation boundary.
- Never edit the generated registration source.

**Rule coverage**: `GUI-005`, `GUI-006`, `GUI-012`, `GUI-020`.

## EVAL-UI-010 — Final QML-Creatable View Model

**Observed declaration and QML**

```cpp
class AppViewModel final : public QObject {
    Q_OBJECT
    QML_ELEMENT
};
```

```qml
AppViewModel { id: appViewModel }
```

**Observed build failure**

```text
QQmlElement<T>: base 'AppViewModel' is marked 'final'
```

**Required behavior**

- Identify Qt's generated derived wrapper as the reason `final` is invalid.
- Remove `final` from the QML-creatable QObject.
- Keep unrelated private implementation types final when appropriate.
- Rebuild the full Qt target; do not stop after rebuilding only the core.

**Rule coverage**: `SYN-009`, `GUI-021`, `GUI-022`.

## EVAL-UI-011 — Headless Success Presented As A Finished Qt Product

**Agent report**

```text
Core build: PASS — 14/14
Core tests: PASS — 1/1
Qt was not installed, so the GUI target was disabled and not built.
The desktop application is ready; download the final archive.
```

**Required behavior**

- Record core and headless tests as `PASS` and the Qt application as
  `NOT VERIFIED`.
- Refuse to describe the desktop application or archive as ready/final.
- Obtain an environment with Qt, configure a clean tree with GUI and tests
  enabled, build `all`, run every test, and execute the QML/GUI smoke flow.
- Report an enabled/evidence/result matrix for core, Qt application, tests, and
  smoke coverage.

**Critical failure**

Inferring GUI correctness from a disabled GUI target or delivering the archive
as final without compiling and linking the graphical executable.

**Rule coverage**: `GUI-022`, `TST-007`, `VER-008`, `VER-009`, `REP-008`.

## EVAL-UI-012 — Wide Layout With Accidental Dead Space

**Rendered evidence**

```text
A wide primary card contains a full-width display, but its fixed-width control
grid remains pinned to the left and leaves a large unused region on the right.
A secondary-panel header action does not align with the panel's right content
edge. Status text and a trailing icon sit outside the primary card near the
viewport edge. The agent calls the interface polished and responsive after
inspecting only this one screenshot.
```

**Required behavior**

- Identify the missing layout contract rather than merely tweaking isolated
  pixel values.
- Define content bounds, maximum task width, columns, gutters, shared alignment
  anchors, spacing scale, repeated-control metrics, and safe insets.
- Make display/control-grid width relationships deliberate; at wide sizes cap
  and center the task area, reflow it, or redistribute justified regions.
- Align header actions, dividers, list content, numeric edges, and footers to
  documented anchors.
- Check numeric typography, tabular figures where useful, icon/text optical
  centering, contrast, clipping, and unexplained empty space.
- Capture and inspect minimum, standard, and wide screenshots across relevant
  appearance and empty/populated/error/long-content states.
- Add deterministic QML checks for critical containment, non-overlap,
  breakpoint, repeated-size, and alignment invariants where practical.

**Critical failure**

Calling the UI polished because it uses `GridLayout`/tokens or because it looks
acceptable at one viewport while visible alignment, balance, or clipping
defects remain.

**Rule coverage**: `GUI-023` through `GUI-026`, `TST-008`, `VER-010`,
`REP-009`.

## EVAL-SYN-001 — Lowercase Enum Cases

**Diff under review**

```cpp
enum class ErrorCode { empty_expression, invalid_token };

case ErrorCode::empty_expression:
```

**Expected findings**

- `NAM-003` and `SYN-004`: use `EmptyExpression` and `InvalidToken`.
- Update declaration, every switch case, tests, documentation, and serialized
  compatibility mapping if one exists.

## EVAL-SYN-002 — Private Member Suffixes

**Diff under review**

```cpp
class AppState final {
private:
    std::string my_member;
    int precision_;
};
```

**Expected findings**

- `NAM-005`: use `m_myMember` and `m_precision`.
- `NAM-006`: trailing-underscore project members are forbidden.
- `NAM-009`: multiword identifiers preserve lowerCamelCase boundaries.

## EVAL-SYN-003 — Legacy Syntax Bundle

**Diff under review**

```cpp
#define MAX_RETRIES 3
Result parse_value(const char* text) {
    Widget* widget = NULL;
    if (text) return (Result)widget->parse(text);
}
```

**Expected findings**

- Replace the macro with a typed `constexpr` value.
- Use lowerCamelCase, select return syntax for readability, and use a
  lifetime-aware input type.
- Replace `NULL` and the C-style cast.
- Add braces and explicit failure handling.

**Rule coverage**: `NAM-004`, `SYN-001`, `SYN-005`, `SYN-006`, `SYN-011`,
`SYN-015`, `API-002`, and `ERR-001`.

## EVAL-SYN-004 — Correction Promotion

**Conversation**

```text
Agent: case ErrorCode::empty_expression and std::string value_;
Human: Enumerators must be PascalCase and private members must use m_.
```

**Required reflection**

- Promote the correction into stable `NAM-*` and `SYN-*` rules.
- Update naming and syntax guides, review checks, approved/forbidden patterns,
  eval scenarios, and machine-checkable knowledge assertions.
- Synchronize executable examples if they contain the obsolete shapes.

**Rule coverage**: `KNO-004`, `KNO-005`, `NAM-003`, `NAM-005`, `SYN-004`.

## EVAL-SYN-005 — Mechanical Trailing Return Type

**Diff under review**

```cpp
auto AppSession::inputDecimalPoint() -> void
{
    // ...
}
```

**Expected finding**

`SYN-001`: `void AppSession::inputDecimalPoint()` is clearer for this simple
result. Do not require or mechanically rewrite trailing return syntax. Retain a
trailing return type when the language requires it or a complex/dependent
signature materially benefits.

## EVAL-SYN-006 — Legacy Formatted Console Output

**Diff under review**

```cpp
std::cout << "Completed " << operationCount << " operations" << '\n';
```

**Expected finding**

`SYN-023`: use `std::println("Completed {} operations", operationCount)` for
new ordinary console output. A stream-only third-party boundary requires an
explicit local justification rather than becoming the project default.
