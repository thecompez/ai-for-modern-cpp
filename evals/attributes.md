# Standard C++ Attribute Decision Evals

Agents MUST reason about the required semantic contract, C++ language level,
compiler behavior, legal declaration/statement target, safety, portability
and measurable impact. Use `docs/agent/ATTRIBUTES.md` and `ATTR-*` in `AGENTS.md`.

## EVAL-ATTR-001 — Blanket Annotation Is Not Modernization

**Diff**

```cpp
[[nodiscard]] std::size_t appendLog(std::string_view line); // Count is optional.
[[nodiscard]] Widget& operator=(const Widget&);
[[maybe_unused]] int unusedData = 42;
```

**Expected findings**

- `ATTR-001` and `ATTR-003`: remove gratuitous `nodiscard` on optional
  side-effect results and normal assignment chaining; preserve mandatory
  error/status checks.
- `ATTR-006`: remove truly dead `unusedData`, do not suppress its warning.
- Critical failure: mark every non-`void` function as `nodiscard`.

## EVAL-ATTR-002 — Precise Switch Fallthrough

**Diff**

```cpp
switch (mode) {
case Mode::Verbose:
    trace();
case Mode::Normal:
    execute();
    break;
case Mode::Minimal:
case Mode::Quiet:
    pause();
    break;
}
```

**Expected findings**

- Add `[[fallthrough]];` after `trace()` only after verifying intentional
  fallthrough. Otherwise fix the control flow.
- Do not mark adjacent empty case labels; obey the null-statement syntax
  and next-label requirements of `ATTR-007`.

## EVAL-ATTR-003 — Assume Is Not Validation

**Diff**

```cpp
[[noreturn]] bool connectToServer();
void process(int value)
{
    [[assume(value != 0)]];
    consume(100 / value);
}
```

**Expected findings**

- Reject `[[noreturn]]` unless every path provably never returns normally.
- Do not use `[[assume]]` for untrusted input, validation or assertions; if
  it is false, behavior is undefined. Use real validation first.
- `ATTR-002`, `ATTR-004`, `ATTR-010`.
- Critical failure: claims the assumption expression runs as a check.

## EVAL-ATTR-004 — Optimization Requires Evidence

**Proposal**

```cpp
struct PublicOptions {
    int retries;
    [[no_unique_address]] EmptyPolicy policy;
};
if (ok) [[likely]] {
    fast();
}
```

**Expected findings**

- Request ABI/address/layout and targeted-compiler evidence before using
  `no_unique_address` on an exported type, noting MSVC behavior.
- Require representative profiling/benchmarks before adding branch hints;
  do not promise a speedup or space saving.
- `ATTR-008`, `ATTR-009`.

## EVAL-ATTR-005 — Language And Compiler Boundaries

**Prompt**

```text
Modernize a C++20 target with [[assume]], [[indeterminate]],
[[carries_dependency]], [[optimize_for_synchronized]],
and [[gnu::always_inline]] on every function.
```

**Expected findings**

- Reject blanket use, wrong-language-version declarations, removed C++26
  dependency attributes, TM TS and unapproved vendor extensions.
- Explain `__has_cpp_attribute`, safe fallbacks, and why feature support
  does not justify introducing an attribute.
- Do not conflate C23 `unsequenced` and `reproducible` with C++.
- `ATTR-001`, `ATTR-002`, `ATTR-011`–`ATTR-014`.

## EVAL-ATTR-006 — Migration And Legitimately Unused Names

**Prompt**

```text
We have approved a new public parseExpression API to replace parseLegacy.
A Qt callback has an unused parameter in all builds; another parameter
is used only in diagnostic builds.
```

**Expected findings**

- Use `[[deprecated("Use parseExpression instead")]]` with a migration
  plan, without deleting a compatibility surface arbitrarily.
- Unname the always-unused parameter, and use `[[maybe_unused]]`
  for the conditionally-used parameter, consistent with Core Guidelines F.9.
- `ATTR-005`, `ATTR-006`.

## EVAL-ATTR-007 — Discarding Mandatory Errors

**Diff**

```cpp
[[nodiscard]] auto saveSettings() -> std::expected<void, SaveError>;
void run()
{
    static_cast<void>(saveSettings());
}
```

**Expected findings**

- Require explicit error handling or propagation; the cast hides a bug.
- In a demonstrably safe reviewed exceptional discard, Core Guidelines ES.48
  prefers `std::ignore = operation();` (include `<tuple>`), but neither
  form is legitimate for bypassing a recoverable failure contract.
- `ATTR-003`, `SYN-008`.

## EVAL-ATTR-008 — Valid Placement And Feature Identity

**Diff**

```cpp
[[fallthrough]] int count = 0;
[[noreturn]] int computeValue();
```

**Expected findings**

- Reject `fallthrough` on a variable; only the null statement is allowed in
  intentional switch fallthrough.
- Verify all paths of `computeValue` before accepting `noreturn`.
- Explain that `alignas` is a separate alignment specifier and that
  `override`, `final`, `noexcept` are not attributes.
- `ATTR-001`, `ATTR-004`, `ATTR-007`, `ATTR-014`.
