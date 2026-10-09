# Standard C++ Attributes: Contract, Scope, and Exceptions

Use this guide whenever adding, removing, or reviewing an attribute in project-owned
C++ code. `AGENTS.md` contains the binding `ATTR-*` rules; this guide supplies
the per-attribute decision procedure. Apply the language rules for the **actual
selected C++ standard and compiler**, not just the language version of this
repository's C++26 executable reference. Derived projects may target C++20+.

## Primary Sources

- [cppreference: attribute specifier sequence](https://cppreference.com/cpp/language/attributes)
  and its linked pages for every standard attribute.
- [C++ Core Guidelines](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines):
  F.9 (unnamed/conditionally unused parameters), E.25 (error reporting),
  ES.48 (avoid casts and do not cast away `nodiscard`), F.8 (pure functions),
  and the general profile/measurement principles.

Cppreference describes language legality and effects; Core Guidelines inform
coding policy. This document distinguishes normative C++ semantics from
repository preferences. A standard attribute is **not** an instruction to use
it on every eligible declaration.

## Decision Procedure (`ATTR-001` / `ATTR-002` / `ATTR-014`)

1. Identify the **real contract**: must-use result, no-return control flow,
   deprecation, intentional fallthrough, conditional unusedness, layout,
   profiling evidence, or a formally proved assumption.
2. Check the exact **target** and grammar: function, type, member, variable,
   label, statement, or null statement. A valid attribute on the wrong target
   is not a valid program.
3. Check the language level and all targeted compilers. Use
   `__has_cpp_attribute(attribute-token)` when a specific capability must be
   feature-gated; ensure a safe, documented fallback. Availability alone does
   not establish semantic parity or an optimization benefit.
4. Prefer portable, explicit language constructs and accurate API design over
   diagnostics suppression or platform-specific hints.
5. Review behavior **with and without** the attribute, including build warnings,
   observable correctness, ABI/layout, error handling, and benchmarks when
   performance is the justification.
6. Keep the smallest coherent patch. Do not inject annotations across a
   codebase solely to satisfy a style checklist.

## Standard Attribute Matrix

| Attribute | First standard | Appropriate when | Avoid when |
|---|---|---|---|
| `[[nodiscard]]`, `[[nodiscard("reason")]]` | C++17, reason C++20 | Ignoring the result is likely a bug or skips required error handling | A side-effecting operation returns an optional informational value |
| `[[noreturn]]` | C++11 | Every path of a function invocation provably never returns normally | Any path can return to its caller |
| `[[deprecated("replacement")]]` | C++14 | An existing API is intentionally being retired with a useful migration path | A symbol is merely old, internal, or has no agreed deprecation decision |
| `[[fallthrough]]` | C++17 | A switch arm intentionally falls into the immediately following case/default | Empty case grouping, accidental fallthrough, or an unrelated statement |
| `[[maybe_unused]]` | C++17 | An entity is **legitimately** unused in some build/configuration | A named unused parameter can instead be unnamed, or code is simply dead |
| `[[likely]]` / `[[unlikely]]` | C++20 | Target-platform profiling supports a stable branch bias and improves performance | Speculative prediction, aesthetics, or already effective PGO |
| `[[no_unique_address]]` | C++20 | Member overlap is intended and layout/ABI consequences are tested | Address identity, stable ABI, or layout compatibility must be preserved |
| `[[assume(expr)]]` | C++23 | A locally proved invariant benefits an optimized hot path | Untrusted input, unchecked validation, or assumed side effects |
| `[[indeterminate]]` | C++26 | Highly exceptional, reviewed low-level storage semantics are required | Ordinary variables, performance guesswork, or bypassing initialization |
| `[[carries_dependency]]` | C++11; removed in C++26 | Existing pre-C++26 code only, under verified legacy dependency contracts | New code or any C++26 source |
| `[[optimize_for_synchronized]]` | TM Technical Specification, **not** ISO C++ standard | Only an explicitly adopted TM TS/toolchain experiment | Portable/mainline production C++ |

**Other syntax:** `alignas` (C++11) can occur in an attribute-specifier
sequence but **is not** a `[[...]]` attribute. `override`, `final`, `explicit`,
`noexcept`, `constexpr` and C++26 contract assertions/annotations are separate
features and should not be classified as these standard attributes. C23
`[[unsequenced]]` and `[[reproducible]]` are **C attributes**, not C++ attributes.
Do not transfer their meaning into C++ by assumption.

## Per-Attribute Rules And Examples

### `[[nodiscard]]` — `ATTR-003` and `SYN-008`

Mark a function whose result must be checked or propagated, including
`std::expected<T, E>` error returns and checks critical to control flow.
Mark pure computations/queries when discarding their value is almost certainly
a mistake. Do **not** mark every non-`void` API, especially normal assignment
operators, mutating APIs, or a logger with an explicitly optional count.

```cpp
[[nodiscard("Handle or propagate the failure")]]
auto saveConfig() -> std::expected<void, SaveError>;

struct [[nodiscard]] ValidationResult {
    bool isValid;
    ErrorCode error;
};
ValidationResult validateInput(std::string_view input);
```

A `[[nodiscard]]` class/enum triggers a discard diagnostic for **by-value**
returns, but not automatically when the function returns `T&` or `const T&`.
A `[[nodiscard]]` function returning a reference still requests a warning.
C++20 reason strings should explain a meaningful failure or recovery action.

Do not turn a required error check into a suppression. In the *rare* case of an
explicitly safe and **reviewed** intentional discard, Core Guidelines ES.48
prefers `std::ignore = operation();` (include `<tuple>`) rather than a
`static_cast<void>(operation())` warning bypass. Always document why skipping
the result is safe; never use either form on unchecked recoverable errors.
The language encourages, but does not universally mandate, a diagnostic.

### `[[noreturn]]` — `ATTR-004`

Apply to a function that **cannot return normally** on any path, such as a
dedicated fatal-error handler that always terminates. Put it on the first
declaration and consistently in visible interfaces. If it does return, behavior
is undefined.

```cpp
[[noreturn]] void terminateWithMessage(std::string_view message);
```

Do not attach it to a function that normally returns an error code, may recover,
or throws only on one branch. It is not a generic error-handling substitute.

### `[[deprecated("reason")]]` — `ATTR-005`

Use for deliberate API migration. Give users a named alternative and enough
context to migrate; keep a compatible transition period when required.

```cpp
[[deprecated("Use parseExpression(text) instead")]]
auto parseLegacy(std::string_view text) -> Expression;
```

Do not annotate every old symbol; avoid introducing deprecation warnings without
an agreed removal/migration plan. The attribute discourages use; it does not
prohibit it or remove an API.

### `[[fallthrough]]` — `ATTR-007`

Apply only to a **null statement** at a real intentional switch fallthrough,
immediately before the next case/default label of the same switch.

```cpp
switch (mode) {
case Mode::Verbose:
    enableTracing();
    [[fallthrough]];
case Mode::Normal:
    performWork();
    break;
}
```

No annotation is needed for consecutive labels with no executable statement
between them. The marker must not be used to conceal an unintended branch.

### `[[maybe_unused]]` — `ATTR-006`

Prefer an **unnamed** parameter when it is never used (Core Guidelines F.9).
Annotate named parameters, structured bindings, locals, or other allowed
entities when use genuinely varies with build flags, assertion modes, or
template instantiation.

```cpp
void onSignal(int /* intentionally unnamed */);

void process([[maybe_unused]] int diagnosticId)
{
#ifdef ENABLE_DIAGNOSTICS
    recordDiagnostic(diagnosticId);
#endif
}
```

Do not suppress warnings from forgotten logic or dead code. It is not a
substitute for removing an unused parameter if the API can change.

### `[[likely]]` and `[[unlikely]]` — `ATTR-008`

These are attached to a statement/label, not to the boolean expression.
Treat them as *profile-guided hints*, not correctness assertions. Collect
representative measurements in relevant build types and on target hardware,
and compare with PGO/normal optimization.

```cpp
if (hasFastPath) [[likely]] {
    processFast();
} else {
    processSlow();
}
```

Do not add hints without evidence, combine contradictory hints on one target,
or assert that a hint improves performance without benchmarks.

### `[[no_unique_address]]` — `ATTR-009`

Only for a non-static, non-bit-field data member. It permits (not guarantees)
address overlap, for example with an empty policy object.

```cpp
struct Policy {};
struct Config {
    int retries {0};
    [[no_unique_address]] Policy policy {};
};
```

Before use, review member address identity, same-type subobjects, tail-padding
reuse, trivial assumptions about `sizeof`, ABI/serialization, and all
compilers. MSVC currently ignores the standard spelling and exposes
`[[msvc::no_unique_address]]`; do not silently substitute it in a public ABI.
Test representative `sizeof`/`alignof` and integration/ABI contracts.

### `[[assume(expr)]]` — `ATTR-010`

This C++23 attribute attaches to a null statement:

```cpp
// Only after a proof that value > 0 on every reaching execution path:
[[assume(value > 0)]];
```

The expression is **not evaluated** by the assumption, so it never performs
checks or side effects. If it would be false at that point, the program has
runtime-undefined behavior. It is not `assert`, input validation, or error
handling. An ordinary invariant guard or assertion is preferable. Require an
explicit proof and measured optimization before using it.

### `[[indeterminate]]` — `ATTR-011`

C++26 distinguishes erroneous from indeterminate values; this attribute opts
specific eligible automatic-storage variables / function parameters into
indeterminate-value semantics and may restore undefined behavior on read.
This conflicts with the normal repository requirement to initialize variables
at declaration (`SYN-002`). **Do not introduce it in normal production code.**
Any low-level exception requires explicit justification, a legality check,
static analysis, and a test proving no read before initialization.

### `[[carries_dependency]]` — `ATTR-012`

Historically conveyed release-consume dependency across function boundaries,
subject to strict first-declaration consistency. **Removed in C++26.** Do not
add it to modern code; keep it only if maintaining a narrowly scoped,
explicitly pre-C++26 legacy interface where the contract and compiler
behavior have been verified. Prefer well-defined, measured atomic ordering
over speculative fences or dependency hints.

### `[[optimize_for_synchronized]]` — `ATTR-013`

This is from the Transactional Memory **Technical Specification**, not part of
the normative ISO C++11/14/17/20/23/26 attribute set. It does not belong in
portable production code. TM TS work requires an explicitly approved,
toolchain-specific scope and verification plan.

## Portability, Vendor Extensions, And Alignment (`ATTR-002`, `ATTR-013`, `ATTR-014`)

Implementation-specific attributes such as `[[gnu::...]]`,
`[[clang::...]]`, and `[[msvc::...]]` are **not portable ISO contracts**.
Use them only at an isolated compiler/platform boundary with measured need,
a safe fallback, and an explanation of behavior on every supported target.
Unknown attributes may be ignored; source acceptance does not establish
equivalent behavior. Use feature testing and compile probes where appropriate.

```cpp
#if defined(__has_cpp_attribute)
#  if __has_cpp_attribute(assume) && __cplusplus >= 202302L
    // A proven local invariant may permit [[assume(condition)]]; here
    // the condition must never be derived from unchecked input.
#  endif
#endif
```

`alignas` is for real alignment requirements (for example, a hardware or
SIMD ABI contract) and should not be mechanically added to types or members.
Validate `alignof`, ABI and target constraints rather than guessing alignment
or cache-line performance.

C++26 also introduces an **annotation syntax** distinct from attributes; do
not treat annotations or contracts as drop-in substitutes for attributes.

## Review And Verification

- Verify exact attribute spelling, scope, target, placement, first declaration,
  language version, and multi-compiler handling.
- Verify the underlying *fact*: an actually mandatory result, truly no-return
  function, intentional fallthrough, migration plan, legitimately unused entity,
  benchmarked branch, safe layout, or proved assumption.
- For `[[nodiscard]]`, review ignored call sites and any use of `std::ignore`;
  failing to propagate `std::expected` errors is a finding even if the function
  was correctly annotated.
- For `[[assume]]` and `[[indeterminate]]`, treat unsound use as a correctness
  risk, not a micro-optimization.
- For `[[likely]]` and `[[no_unique_address]]`, require performance/ABI evidence
  rather than inferred improvement.
- For conditional attributes, verify the fallback path and test the exact
  targeted compiler/standard combinations.
- Do not claim compiler portability or optimization gains without build or
  measurement evidence. Static knowledge-contract tests check documentation
  presence; they are **not** a substitute for compiling production code.

## Source Links

- [C++ standard attributes](https://cppreference.com/cpp/language/attributes)
- [C++ Core Guidelines F.9](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Rf-unnamed)
- [C++ Core Guidelines ES.48](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Res-casts)
- [C++ Core Guidelines E.25](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Re-throw)
