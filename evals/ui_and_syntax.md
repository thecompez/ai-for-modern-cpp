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
- Use lowerCamelCase, a trailing return type, and a lifetime-aware input type.
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
