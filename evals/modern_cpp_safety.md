# C++20–C++26 Safety And Feature Decision Scenarios

These are **agent behavior evaluations**, not compiler-run tests.
Required references: `AGENTS.md` (`SAFE-*` / `FEAT-*`),
`docs/agent/SAFETY_AND_LIFETIME.md`,
`docs/agent/CPP20_26_FEATURES.md` and cppreference.

## EVAL-SAFE-001 — Truncated Packet And Invalid Span

**Diff:**
```cpp
std::uint32_t read(std::span<const std::byte> packet,
                   std::size_t offset)
{
    return std::to_integer<std::uint32_t>(packet[offset]);
}
```

**Expected:** `SAFE-001`: validate `offset < packet.size()` and the
construction/storage lifetime of the span. Return a recoverable error on
invalid input, not a default success. `std::span::at` is C++26-only and
cannot repair a dangling span.

## EVAL-SAFE-002 — Dangling View And Ranges

**Diff:**
```cpp
std::string_view label()
{
    std::string name = "temporary";
    return name;
}
```

**Expected:** `SAFE-002`: return an owning `std::string` or bind the view
to longer-lived storage. Explain why `borrowed_range` and
`ranges::dangling` do not magically extend the lifetime of an
underlying temporary. For coroutine suspension, verify owners separately.

## EVAL-SAFE-003 — Overflow Before Allocation

**Diff:**
```cpp
auto bytes = count * elementSize;
if (bytes > maximumBytes) {
    return std::unexpected(Error::TooLarge);
}
std::vector<std::byte> buffer(bytes);
```

**Expected:** `SAFE-003`: detect multiplication overflow *before*
computing it. C++26 `ckd_mul(&bytes, count, elementSize)` returns
`true` on overflow; the overflow result must not be consumed.
Use checked division-based fallback for C++20/23. Reject negative
to unsigned size conversion without representability validation.

## EVAL-SAFE-004 — Prefix-Only Parse Accepted

**Diff:**
```cpp
int value {};
auto result = std::from_chars(text.data(),
                             text.data() + text.size(), value);
if (result.ec == std::errc {}) {
    save(value);
}
```

**Expected:** `SAFE-004`: if full consumption is required, also check
`result.ptr == text.data() + text.size()`. Validate domain range.
No silent acceptance of `"123junk"`.

## EVAL-SAFE-005 — Stuck Worker On Destruction

**Diff:**
```cpp
std::jthread worker([](std::stop_token token) {
    while (true) { blockForever(); }
});
```

**Expected:** `SAFE-006`: stop is cooperative and `~jthread` performs
stop request and join, which can block. Add bounded interruptible
blocking, stop checks and ownership review. Stop callbacks must not
throw and shared state requires synchronization.

## EVAL-SAFE-006 — Suspended Coroutine With Borrowed Input

**Diff:**
```cpp
Task persist(const std::string& document)
{
    co_await scheduleLater();
    write(document);
}
```

**Expected:** `SAFE-007`: reference may dangle after suspension.
Transfer ownership into a coroutine-safe object and define cancellation,
frame destruction and executor lifetime.

## EVAL-SAFE-007 — Mistaken C API Ownership

**Proposal:**

```text
Use &uniquePtr.get() as a T** output parameter, then forget
the C function's failure code and the vendor-specific free function.
```

**Expected:** `SAFE-008`: reject invalid output pointer syntax and
mismatched ownership. Where C++23-supported, evaluate `std::out_ptr`
with a custom deleter and tested error convention. Explain why
`std::inout_ptr` is different.

## EVAL-SAFE-008 — Contracts As Authorization

**Proposal:**

```cpp
void deleteAccount(Request request)
    pre(isAuthorized(request));
```

**Expected:** `SAFE-010`: authorization must be a guaranteed runtime
check with explicit failure. C++26 contract evaluation can be ignored;
a contract is not security validation. Require version probing.

**Critical failure:** calls the contract a reliable authorization gate.

## EVAL-SAFE-009 — Hardened STL Means No Checking

**Proposal:**

```text
The library is in hardened mode, so access input[index] directly
without validating index or pointer/extent. Sanitizer tests passed.
```

**Expected:** `SAFE-001` / `SAFE-011` / `SAFE-013`:
hardened precondition violations may terminate; non-hardened
violations can be UB. Sanitizers do not prove safety. Keep checks and
negative tests.

## EVAL-SAFE-010 — Fixed Capacity And Non-Owning Callback

**Proposal:**

```cpp
std::inplace_vector<Item, 8> queue;
queue.push_back(next()); // Could already contain 8 elements.
std::function_ref<void()> callback = [&local] { use(local); };
// callback is stored and invoked asynchronously.
```

**Expected:** `FEAT-001` / `FEAT-002` and `SAFE-002`:
check fixed capacity; do not retain a non-owning function_ref
or its borrowed capture beyond the callable lifetime. Require actual
C++26 library availability; use an owning callback if storage is required.

## EVAL-SAFE-011 — Dynamic Formats And Information Disclosure

**Proposal:**

```cpp
std::println(std::dynamic_format(untrustedText), secretToken);
```

**Expected:** `SAFE-009` and `FEAT-003`: use a literal format and
pass untrusted text as data. Never log secrets; rate-limit/bound
logging. Verify C++26 dynamic_format support and spelling rather
than assuming a known compiler implements it.

## EVAL-SAFE-012 — New Feature Without Compiler Support

**Prompt:**

```text
Turn on C++26 and require <meta>, <contracts>, <hive>, and
<stdckdint.h> across Linux, macOS, and Windows immediately.
```

**Expected:** `FEAT-001` and `FEAT-004`: inspect the actual
toolchain, standard library feature macros, Qt kit and build/link
probe; isolate optional capabilities or select safe C++20/23
fallbacks. Do not downgrade module architecture, claim untested
portability, or add feature gates without a real requirement.
