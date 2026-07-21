# Modern C++ Syntax And Style

Use this guide whenever writing or reviewing C++ syntax. Canonical rules:
`SYN-*` and `NAM-*` in `AGENTS.md`.

The purpose of a style rule is to make ownership, type, control flow, and intent
immediately legible to both humans and agents. Do not trade clarity for novelty.

## Identifier Matrix

| Entity | Required shape | Correct | Incorrect |
|---|---|---|---|
| Type, class, struct, concept | PascalCase | `ExpressionParser` | `expression_parser` |
| `enum class` enumerator | PascalCase | `EmptyExpression` | `empty_expression` |
| Function | lowerCamelCase | `parseExpression` | `parse_expression` |
| Parameter or local | lowerCamelCase | `expressionText` | `expression_text` |
| Private/protected member | `m_` + lowerCamelCase | `m_expressionText` | `my_member`, `mymember_` |
| Boolean | lowerCamelCase predicate | `isReady`, `hasError` | `readyFlag`, `error_bool` |
| Constant | lowerCamelCase with type guarantees | `maximumDepth` | `MAX_DEPTH` |
| QML type/file | PascalCase | `PrimaryActionButton.qml` | `primary_action_button.qml` |
| QML id/property/signal | lowerCamelCase | `resultDisplay` | `result_display` |

## Enumerations And Switches

Use scoped enumerations and PascalCase enumerators.

**Correct**

```cpp
enum class ErrorCode {
    EmptyExpression,
    InvalidToken,
    DivisionByZero
};

[[nodiscard]] auto describeError(ErrorCode errorCode) -> std::string_view
{
    switch (errorCode) {
    case ErrorCode::EmptyExpression:
        return "Expression must not be empty.";
    case ErrorCode::InvalidToken:
        return "Expression contains an invalid token.";
    case ErrorCode::DivisionByZero:
        return "Division by zero is not allowed.";
    }

    std::unreachable();
}
```

**Incorrect**

```cpp
enum ErrorCode {
    empty_expression,
    invalid_token
};

case ErrorCode::empty_expression:
```

The incorrect form violates `NAM-003`, `SYN-004`, and strong type scoping.

## Class Shape

**Correct**

```cpp
class ExpressionEvaluator final {
public:
    explicit ExpressionEvaluator(Precision precision);

    [[nodiscard]] auto evaluate(std::string_view expressionText) const
        -> std::expected<double, ErrorCode>;

private:
    Precision m_precision;
    bool m_isTracingEnabled {false};
};
```

**Incorrect**

```cpp
class expression_evaluator {
public:
    expression_evaluator(Precision precision);
    double evaluate(std::string expression_text);

private:
    Precision my_member;
    bool tracing_enabled_;
};
```

Private members are always `m_` plus lowerCamelCase. A trailing underscore does
not become acceptable because another framework or style guide uses it.

## Functions And Results

Project functions use trailing return types. Mark important results
`[[nodiscard]]`, preserve `const` correctness, and use explicit failure types.

**Correct**

```cpp
[[nodiscard]] auto loadExpression(std::filesystem::path path)
    -> std::expected<Expression, LoadError>;
```

**Incorrect**

```cpp
Expression load_expression(std::filesystem::path path);
```

The incorrect form hides the failure contract and violates naming and function
syntax rules.

## Initialization And Mutability

- Initialize every variable at declaration.
- Prefer `const` when a local does not change.
- Give data members safe default state when meaningful.
- Use braces when they prevent narrowing or clarify construction.
- Do not use a default value to disguise an error.

```cpp
const auto tokenCount = tokens.size();
auto result = std::optional<Result> {};
auto retryCount = std::size_t {0};
```

## Casts And Nullability

Use `nullptr`. Use named casts only when the conversion is intentional and
locally understandable.

```cpp
const auto itemCount = static_cast<std::size_t>(validatedCount);
auto* target = dynamic_cast<Target*>(baseObject);
```

`reinterpret_cast` requires a low-level boundary and explanation. C-style casts
are never a shortcut around type design.

## Control Flow

- Always use braces.
- Prefer early returns when they reduce nesting.
- Keep conditions named when their meaning is not obvious.
- Do not combine unrelated mutation and decisions in one expression.
- Use exhaustive `switch` handling for closed alternatives.

**Correct**

```cpp
if (expressionText.empty()) {
    return std::unexpected{ErrorCode::EmptyExpression};
}
```

**Incorrect**

```cpp
if (expression_text.empty()) return false;
```

## Namespace And Alias Scope

Do not place `using namespace` at namespace scope. Prefer qualified names or a
narrow alias close to its use.

```cpp
namespace ranges = std::ranges;

auto findRule(std::span<const Rule> rules) -> Iterator
{
    return ranges::find_if(rules, predicate);
}
```

Use `using` for project-owned aliases:

```cpp
using ParseResult = std::expected<Expression, ErrorCode>;
```

Do not introduce new `typedef` declarations.

## Class And Source Structure

Order a class for contract-first reading:

```text
public constructors and special members
public operations
protected extension points, only when intentional
private operations
private data
```

Invariant-bearing data remains private. A `struct` may expose data only when it
is deliberately a transparent passive value without a hidden invariant.
Constructor initializer lists follow declaration order.

Order a module implementation for predictable reading:

```text
module declaration
imports
namespace
member/public definitions
private local helpers
```

## Lambdas And Lifetime

Use the narrowest capture list that explains ownership. A lambda that escapes
the current call must not casually use `[&]`.

```cpp
auto task = [request = std::move(request), owner = m_owner]() mutable {
    return owner->execute(std::move(request));
};
```

Before storing or dispatching a lambda, verify the lifetime of every captured
pointer, reference, Qt object, and cancellation token.

## `auto` And Iteration

Use `auto` when the initializer communicates the type or repeating the type
adds noise. Spell out a domain type when it makes ownership, precision, or a
conversion materially clearer. Prefer range-based loops and stable range
algorithms, but do not force them when an indexed algorithm is clearer.

## Macro Policy

Macros are limited to unavoidable preprocessing and external compatibility.
Use language constructs for project-owned constants and behavior.

```cpp
inline constexpr auto maximumDepth = std::size_t {64};
```

Do not write:

```cpp
#define MAX_DEPTH 64
#define RETURN_IF_ERROR(value) /* hidden control flow */
```

## Review Sequence

1. Check module and namespace identity.
2. Check every exported and project-owned identifier.
3. Check enum declarations and every `case` label.
4. Check private/protected data member prefixes.
5. Check initialization, constness, casts, nullability, and control-flow braces.
6. Check result/error contracts and `[[nodiscard]]`.
7. Reject unrelated formatting churn during functional changes.
