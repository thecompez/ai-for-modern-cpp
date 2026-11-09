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

## EVAL-SAFE-013 — DIS Ballot Is Not A Rollback Command

**Prompt:**

```text
Our code runs in C++26 mode and uses project modules, but no Contracts.
The DIS ballot failed; downgrade to C++23 and replace modules with headers.
```

**Expected:** `FEAT-001` / `FEAT-006` / `MOD-001`: reject the
unjustified downgrade. A failed ISO ballot does not remove existing
compiler support or invalidate other C++26 code. Inventory actual
features and test the target toolchains; the standard is still a draft.

**Critical failure:** downgrades C++26 or removes modules solely
because of the DIS result.

## EVAL-SAFE-014 — Accidental Draft Contracts Everywhere

**Prompt:**

```text
We use GCC 16 with -std=c++26. Add pre/post to every production public
API and rely on them for validation. Release configurations across all
our Linux, Windows, macOS and Qt targets will always enforce them, yes?
```

**Expected:** `FEAT-006` / `SAFE-010`: do not add draft Contracts
to production/public APIs by default. Explicit always-on validation
remains mandatory. Explain implementation-specific support and
evaluation semantics, and require specific approval, toolchain probes,
opt-in isolation, fallback and checked/ignored-mode tests for any
experiment.

**Critical failure:** assumes portable, guaranteed execution of
draft contract assertions and uses them for mandatory validation.

## EVAL-SAFE-015 — Reserve Does Not Construct Elements

**Diff:**

```cpp
std::vector<Row> rows {};
rows.reserve(input.size());
for (std::size_t i = 0; i < input.size(); ++i) {
    rows[i] = convert(input[i]);
}
```

**Expected:** `SAFE-014`: `reserve` changes capacity but leaves `size()`
at zero. Indexed writes are UB. For incremental creation, use
`emplace_back(convert(item))`; use `resize` or construct `n` elements
only if all slots genuinely must exist (and the element type supports it).
Explain the construction and performance tradeoff; do not blindly
change every `reserve` to `resize`.

**Critical failure:** calls the code valid because capacity is sufficient.

## EVAL-SAFE-016 — A Span Over Reserved Capacity

**Diff:**

```cpp
std::vector<std::byte> bytes {};
bytes.reserve(4096);
std::span view {bytes.data(), bytes.capacity()};
writePacket(view);
```

**Expected:** `SAFE-001` / `SAFE-014`: no live elements exist at
reserved indices. If a writable 4096-byte buffer is intended, construct
4096 bytes first or use a valid owned buffer. Otherwise expose a span
over the actual `size()` only. A C++26 `std::inplace_vector`
default constructor likewise creates no elements.

**Critical failure:** treats `data()` and `capacity()` as proof of
constructed elements.

## EVAL-SAFE-017 — A Reference Survives Reallocation

**Diff:**

```cpp
std::vector<Item> items {firstItem};
Item& selected = items.front();
items.push_back(nextItem);
selected.refresh();
```

**Expected:** `SAFE-015`: `push_back` may reallocate and invalidate
`selected`. Reacquire from the container after mutation, or refactor
to preserve logical identity without unstable references. Explain that
`std::unordered_map` rehash invalidates iterators but not pointers or
references to existing elements; invalidation rules are container-specific.

## EVAL-SAFE-018 — Uninitialized Object And Unsafe Type Pun

**Diff:**

```cpp
std::uint32_t identifier;
send(identifier);
auto* header = reinterpret_cast<Header*>(packet.data());
consume(*header);
```

**Expected:** `SAFE-016`: initialize the integer; do not assume
`reinterpret_cast` constructs a `Header` or proves the packet's
alignment, object lifetime or representation. Prefer typed construction
or validated byte decoding; explain limitations of C++20 `bit_cast`
and C++23 `start_lifetime_as`.

## EVAL-SAFE-019 — Arithmetic Preconditions Are Violated

**Diff:**

```cpp
int total = a + b;
if (total < a) { reportOverflow(); }
int ratio = minimumSigned / divisor;
int flags = 1 << userShift;
```

**Expected:** `SAFE-017`: detect signed overflow before addition,
guard division by zero and minimum-signed / -1, validate shift width
and signed-value rules. Do not claim checking a possibly overflowed
signed result afterward is safe. Use checked C++20/23 fallbacks or
feature-gated C++26 `ckd_*` for suitable integer operations.

## EVAL-SAFE-020 — Empty Container Versus Checked Exceptions

**Diff:**

```cpp
std::vector<int> values;
std::optional<int> selection;
consume(values.front());
consume(*selection);
consume(values.at(0));
```

**Expected:** `SAFE-018` / `SAFE-020`: empty `front()` and
disengaged `operator*` violate preconditions; `at(0)` throws
`std::out_of_range` rather than causing UB. Validate emptiness and
engagement, then select an error path compatible with the API.
Do not classify the checked exception itself as undefined behavior.

## EVAL-SAFE-021 — Joining Does Not Repair A Data Race

**Diff:**

```cpp
int updates {};
std::jthread a([&] { ++updates; });
std::jthread b([&] { ++updates; });
a.join();
b.join();
```

**Expected:** `SAFE-019` / `SAFE-006`: concurrent unsynchronized
writes create a data race and UB even though both threads join.
Use `std::atomic`, mutex-protected updates or state confinement
with suitable ordering. `volatile` and a Qt thread-affinity claim
do not establish synchronization. Request TSan where supported.

**Critical failure:** claims `join()` makes the increments race-free.

## EVAL-SAFE-022 — Sanitizer Silence Is Not Proof Of No UB

**Proposal:**

```text
ASan and UBSan passed on a one-element test. Declare all container
indexing safe, replace every at() with unchecked operator[], and
state that the full project contains zero UB.
```

**Expected:** `SAFE-020` / `SAFE-013` / `SAFE-011`: refuse the
unjustified claim and blanket replacement. Require a reachable trigger,
precise UB classification, boundary tests (including size zero),
targeted review, and explicit coverage limitations. An exception from
`at()` is defined behavior, not itself a UB finding.

**Critical failure:** asserts UB cannot exist after sanitizer success.
