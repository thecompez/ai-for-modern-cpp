# C++20–C++26 Safety, Lifetime, and Security

This guide is mandatory for **new or changed** untrusted-input processing,
pointer/view lifetimes, binary parsing, thread/coroutine tasks, foreign APIs,
and security-sensitive numerical operations. The canonical `SAFE-*` rules are
in `AGENTS.md`; this guide gives executable reasoning and positive/negative
examples. Do not retroactively rewrite unrelated working code.

**Reference basis:** cppreference's [C++20](https://en.cppreference.com/cpp/20),
[C++23](https://en.cppreference.com/cpp/23),
[C++26](https://en.cppreference.com/cpp/26), [object
lifetime](https://en.cppreference.com/cpp/language/lifetime) and
[reference initialization](https://en.cppreference.com/cpp/language/reference_initialization).
Compiler/library availability is **not** implied by requesting `-std=c++26`.
Use `__cpp_lib_*`/`__cpp_*` tests and compile probes for conditional facilities.

## Hazard-to-Control Matrix

| Risk | First relevant facility | Required decision |
|---|---|---|
| Out-of-bounds bytes and indices | `std::span` (C++20), `span::at` (C++26) | Check lengths, offsets, extents **before** access; views do not validate external sizes |
| Dangling references/iterators | `borrowed_range`, `ranges::dangling` (C++20) | Prove ownership of every referenced byte/object across return, storage, await and callback |
| Integer wrap and undersized allocation | `std::midpoint` (C++20), `ckd_*` (C++26) | Check overflow and narrowing before size calculation, pointer arithmetic or allocation |
| Threads outliving state | `std::jthread` and `std::stop_token` (C++20) | Explicit stop protocol, ownership, synchronization and verified termination |
| Coroutine suspension | Coroutines (C++20), `std::generator` (C++23) | Own values across suspension; enforce task/handle destruction and cancellation |
| C API ownership confusion | `std::out_ptr`/`std::inout_ptr` (C++23) | Match allocation and deleter; honor error/out-parameter semantics |
| Raw-storage lifetime/type punning | `std::start_lifetime_as` (C++23), `std::bit_cast` (C++20) | Alignment, size, representation, lifetime and endianness must be proved |
| Lost failures | `std::expected` (C++23) | Check/propagate error before consuming a value, never fabricate success |
| Untrusted formatted data | `std::format` (C++20), `std::print` (C++23) | Treat external strings as *data*, not format templates; bound output |
| Pretend security guarantees | C++26 contracts and hardened library | Contracts/hardening do not replace input validation and do not guarantee recovery |
| Hostile paths/diagnostics | `std::filesystem` and `std::source_location` (C++20) | Restrict trust boundaries, prevent TOCTOU, redact sensitive paths and data |

## SAFE-001: Bounds And Non-Owning Buffer Views

Prefer `std::span<T>`/`std::span<const T>` for existing contiguous storage
with a proven lifetime. It is a **non-owning pair of pointer and extent**,
not a memory sanitizer or lifetime owner. Do not build a span from an
incorrect pointer/length pair. Length multiplication, offset addition and
subspan preconditions can fail before an element is accessed.

**Correct (C++20): validate before index or slicing**

```cpp
[[nodiscard]] auto readByte(std::span<const std::byte> data,
                            std::size_t offset)
    -> std::optional<std::byte>
{
    if (offset >= data.size()) {
        return std::nullopt;
    }
    return data[offset];
}
```

**Incorrect:** `data[offset]` with an unchecked external offset, or
`std::span{ptr, untrustedCount}` without proving the allocation covers it.
`std::span::at` (C++26) throws `std::out_of_range` on a bad index **when
implemented**, but does not fix an invalid underlying span. Likewise,
`std::mdspan` (C++23) is non-owning; multidimensional extents, product
overflow, layout stride, and the storage size must agree.
`std::mdspan::at` (C++26) does not repair wrong extents or lifetimes.

## SAFE-002: Ownership, Temporaries, Ranges And Views

`std::string_view`, `std::span`, iterators, ranges pipelines, and Qt signals
or callbacks do not extend the lifetime of external storage. Do not return a
view of a local `std::string`/`std::vector` or retain a view of a temporary.

**Incorrect:**

```cpp
std::string_view makeLabel()
{
    std::string owned = "user";
    return owned; // Dangling on return.
}
```

**Correct:**

```cpp
std::string makeLabel()
{
    return "user"; // Owning return value.
}
```

C++20 `std::ranges::borrowed_range` and `std::ranges::dangling` protect
**specific range algorithm results**, not arbitrary references kept by
adapters. A borrowed range does not keep referenced underlying storage
alive; always prove that its source owner outlives the consumer.

For C++23 generic reference-wrapping types, consider
`std::reference_constructs_from_temporary` and
`std::reference_converts_from_temporary` where available to reject
temporaries. Traits are aids, not substitutes for a real lifetime proof.
Avoid aggregate reference-member initialization with parentheses when it
would create a dangling reference to a temporary.

## SAFE-003: Integer Overflow, Sizes And Signedness

Validate input lengths before addition, multiplication, index conversion,
subtraction or allocation. A cast to `std::size_t` is **not** input
validation; negative signed values may become very large unsigned values.
Do not overflow first and check afterward.

**Correct, C++20-compatible allocation-size check:**

```cpp
[[nodiscard]] auto requiredBytes(std::size_t count,
                                 std::size_t width)
    -> std::optional<std::size_t>
{
    if (width != 0 &&
        count > std::numeric_limits<std::size_t>::max() / width) {
        return std::nullopt;
    }
    return count * width;
}
```

**C++26 only (`<stdckdint.h>`):**

```cpp
std::size_t bytes {};
if (ckd_mul(&bytes, count, elementSize)) {
    return std::unexpected(SizeError::Overflow);
}
// The result is usable only on the no-overflow branch.
```

`ckd_add`/`ckd_sub`/`ckd_mul` return **true on overflow**. The result
is written even on overflow, but the wrapped value MUST NOT be treated as
a safe allocation size. Their declarations are in the global namespace;
do **not** assume `std::ckd_mul` exists. Confirm header/toolchain support.

Prefer `std::midpoint(a,b)` (C++20) over overflowing integer `(a+b)/2`.
Use `std::in_range<T>(value)` (C++20) before narrowing external values
when the intent is representability.

## SAFE-004: Parsing And Serialization Boundaries

For numeric input, check **both** `from_chars_result.ec` and `ptr == last`
when the grammar requires complete consumption. Detect unsupported encodings,
lengths, trailing garbage, range errors and unexpected null bytes; never
silently coerce invalid values into a default success.

**Correct: complete integer parse (facility since C++17):**

```cpp
[[nodiscard]] auto parsePort(std::string_view input)
    -> std::optional<unsigned>
{
    unsigned port {};
    const auto [ptr, error] =
        std::from_chars(input.data(), input.data() + input.size(), port);
    if (error != std::errc {} || ptr != input.data() + input.size() ||
        port == 0 || port > 65535) {
        return std::nullopt;
    }
    return port;
}
```

Use `std::endian` (C++20) and `std::byteswap` (C++23) when decoding binary
formats. `std::bit_cast` (C++20) is not a deserializer and does not
implicitly change byte order, validate padding, or allow mismatched sizes.
`std::start_lifetime_as<T>` (C++23) does not justify misaligned storage,
incorrect buffer size, invalid representation, or unexpected object
lifetimes; prefer copying/explicit decoding for untrusted packets.

## SAFE-005: Recoverable Errors And Fallbacks

C++23 `std::expected<T,E>` is appropriate for recoverable errors;
`std::optional<T>` means genuinely absent without an error.
Do not call `expected::value()` assuming success; inspect, recover,
or propagate the error. Monadic chaining (C++23) does not remove this
responsibility. Never replace a failed parse, network operation, or save
with a fabricated success-shaped default. Annotate important results
using `SYN-008`.

**Correct:**

```cpp
auto result = parseDocument(source);
if (!result) {
    return std::unexpected(result.error());
}
consume(*result);
```

A failed optional value is not automatically an error. Choose the
vocabulary type according to the operation contract, not aesthetics.

## SAFE-006: Thread Lifetime, Stop And Synchronization

Prefer owned `std::jthread` to unmanaged `std::thread` when a task should
request stop and join on destruction. A stop request is **cooperative**:
a worker that ignores it can make destruction block indefinitely.
Never assume that `request_stop()` kills an OS thread or interrupts every
blocking API. Stop callbacks execute synchronously on the requesting
thread; they must not throw. Synchronize shared data (`mutex`,
`atomic`, channels/ownership transfer); `volatile` does not solve races.

```cpp
std::jthread worker([](std::stop_token stop) {
    while (!stop.stop_requested()) {
        doOneBoundedUnitOfWork();
    }
}); // Destructor requests stop and joins; bounded work must terminate.
```

Review condition-variable wakeups (including spurious wakeups),
`atomic::wait/notify` (C++20) publication and memory order,
`latch`/`barrier`/`semaphore` (C++20) participant counts and deadlock
paths. A reference captured across thread boundaries needs a proven
lifetime. No detached worker may access short-lived state.

## SAFE-007: Coroutine Suspension And Cancellation

A coroutine frame owns **by-value** parameters but its by-reference
parameters and captured references can dangle after a suspension. The
coroutine handle is non-owning; use an owner that destroys its frame
exactly once. Enforce cancellation, executor lifetime, and who destroys
pending frames. Suspended coroutines must not reference objects torn
down by UI navigation or a request timeout.

`std::generator` (C++23) is a synchronous range generator, not a
drop-in background task system. Use it only when lazy production
improves code clarity and verify iterator/frame lifetimes.

**Incorrect:**

```cpp
Task asyncSave(const std::string& text)
{
    co_await suspendAndSchedule();
    writeText(text); // The caller's string may already be destroyed.
}
```

**Correct by design:** a task owns an independent `std::string` or an
explicit owner token for the entire suspension period, and its lifecycle
is joined/cancelled before those owners are destroyed. Never use an
unsafe borrowed reference simply to avoid a copy.

## SAFE-008: Foreign/C API Resource Adoption

At a C API that writes `T**`, C++23 `std::out_ptr` may adapt a correctly
typed smart pointer; `std::inout_ptr` is for APIs that both consume and
replace the current pointer. Both have specific reset/adoption behavior.
Verify allocator/free-function pairs, null-on-error conventions, prior
ownership, and custom deleters. A `shared_ptr` reset usually requires
an explicit deleter. An `out_ptr` temporary must not outlive the smart
pointer or the arguments it references.

**Correct shape (when the C function follows the stated ownership contract):**

```cpp
using FileHandle = std::unique_ptr<CFile, CFileCloser>;
FileHandle handle {nullptr};
const int code = c_open_file(std::out_ptr(handle));
if (code != 0) {
    return std::unexpected(OpenError {code});
}
```

Never substitute `&smartPointer.get()` for an output parameter and
never assume a C function's error implies a null output pointer.

## SAFE-009: Format Strings, Logging And Information Exposure

Keep untrusted input in **data arguments**, never construct format
templates directly from it. C++20 `std::format` validates ordinary
literal format strings; C++26 dynamic/runtime format mechanisms still
require explicit trust decisions. Formatting does not escape SQL, HTML,
shell, JSON or log delimiters, and does not prevent resource exhaustion.

**Correct:**

```cpp
std::println("User input: {}", untrustedText);
```

Never print secrets, tokens, credentials or personally identifying
data by default. C++20 `std::source_location` and C++23
`std::stacktrace` can reveal file paths/build structure; redact and
control retention. Do not log arbitrary unbounded user-controlled data.

## SAFE-010: C++26 Contracts Are Not Input Validation

C++26 `pre`, `post` and `contract_assert` describe programmer
preconditions, postconditions and internal invariants. Evaluation
semantics are implementation-defined (`ignore`, `observe`,
`enforce`, `quick-enforce`); **predicate execution and termination
are not guaranteed for every build.** Avoid state changes inside
contract predicates. Do not rely on contracts for hostile network
requests, auth, persistence integrity or security checks.

**Correct pattern:**

```cpp
if (!isAuthorized(request)) {
    return std::unexpected(AuthError::Denied);
}
// Optional verified internal contract for a proven invariant, if enabled:
// contract_assert(internalState.isConsistent());
```

Do not introduce C++26 syntax without compiler and library probes
(`__cpp_contracts` / `__cpp_lib_contracts`). Existing `assert` statements
may also compile out; use runtime checks for recoverable errors.

## SAFE-011: Hardened Standard Library Is Defense In Depth

C++26 standardized hardening describes selected library preconditions;
**a non-hardened implementation retains undefined behavior** on violation.
A hardened implementation can terminate rather than recover. Verify
compiler/STL configuration; do not claim that `operator[]` universally
performs bounds checking. `span::at` and `mdspan::at` (C++26 where
supported) perform explicit range checking; they still require valid
underlying storage.

Always validate untrusted offsets and lengths even if sanitizers,
assertions, contract checks, or hardened libraries are enabled.

## SAFE-012: Filesystem, Trust And Time-of-Check/Time-of-Use

Paths formed from untrusted input can escape an approved root using
`..`, symlinks, mount changes, or platform-specific interpretation.
`std::filesystem::canonical`/`weakly_canonical` are useful but a
separate path check followed by open can still race (TOCTOU). Apply
platform-appropriate secure directory-relative handle-based open
semantics, authorization and open-handle verification where security
matters. Avoid broad exceptions swallowed as success.

These are general security obligations, not novel C++20 library
guarantees. Keep OS-specific enforcement inside `PLT-*` boundaries.

## SAFE-013: Diagnostics And Verification

For production changes in these categories, validate on the smallest
affected target with realistic boundary cases, then add negative tests:
empty/truncated/oversized input, offset equal to size, overflow, very
large counts, negative-to-unsigned conversion, trailing garbage, null
foreign pointers, cancellation during destruction, coroutine suspension
after owner release, and dangerous paths. Run sanitizers **where
supported**: ASan/UBSan for memory/UB and TSan separately for races
(toolchain/runtime-dependent). Sanitizer success cannot prove absence
of memory-safety bugs. Report untested platforms and feature gates
explicitly; do not claim that a documentation test compiled examples.

## Reference Links

- [C++20 features](https://en.cppreference.com/cpp/20)
- [C++23 features](https://en.cppreference.com/cpp/23)
- [C++26 and library-hardening status](https://en.cppreference.com/cpp/26)
- [Lifetime](https://en.cppreference.com/cpp/language/lifetime)
- [Borrowed ranges](https://en.cppreference.com/cpp/ranges/safe_range)
- [Range dangling result](https://en.cppreference.com/cpp/ranges/dangling)
- [C++20 joining threads](https://en.cppreference.com/cpp/thread/jthread)
- [C++20 coroutine lifetime](https://en.cppreference.com/cpp/language/coroutines)
- [C++23 foreign output pointer adapter](https://en.cppreference.com/cpp/memory/out_ptr_t)
- [C++23 raw-storage lifetime](https://en.cppreference.com/cpp/memory/bless)
- [C++26 checked arithmetic](https://en.cppreference.com/cpp/numeric/ckd_mul)
- [C++26 span bounds checking](https://en.cppreference.com/cpp/container/span/at)
- [C++26 contracts](https://en.cppreference.com/cpp/language/contracts)
- [C++ Core Guidelines](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines)
