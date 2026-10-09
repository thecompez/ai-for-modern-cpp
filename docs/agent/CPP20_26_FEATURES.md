# Choosing Modern C++20, C++23, and C++26 Features

This is a **decision catalogue**, not a checklist that forces all language
features into every codebase. Consult the higher-priority `AGENTS.md` rules,
`SAFETY_AND_LIFETIME.md` for high-risk work, `ATTRIBUTES.md` for attributes,
and the exact selected compiler/standard library capability tables.

## FEAT-001 — Capability And Release Gate

Target language level does not guarantee corresponding **library** support.
Before introducing a C++23/26 feature:
1. Confirm the requested standard, minimum compiler, standard library, Qt
   kit and deployed runtime (`__cplusplus` alone is insufficient).
2. Check `__cpp_*`/`__cpp_lib_*` in `<version>` where relevant, and compile/link
   an isolated probe against the real target.
3. Choose a correct, maintainable fallback rather than weakening the project's
   standard or turning off required features.
4. Keep optional support isolated. Experimental partial C++26 support does
   not justify requiring the feature across all build targets.

No wholesale migration or library dependency is authorized just because
a newer feature is available.

## C++20: New Tools And Meaningful Use

| Facility | Recommended when | Do not use when |
|---|---|---|
| `concepts` and `requires` | Template contracts clarify valid operations and errors | Constraints merely rename `typename` or encode irrelevant details |
| Modules | Stable project-owned boundaries under repository `MOD-*` | Compatibility tooling still requires isolated textual boundaries |
| Coroutines | Delayed/suspended state machine has explicit ownership | A synchronous call is simpler or references may dangle during suspend |
| Ranges and views | Composable transformations reduce mistakes and owners live long enough | Pipeline laziness, invalidation, and hidden allocations are unclear |
| `std::span`, `std::string_view` | Borrowed contiguous/string inputs with proven owners | Views may outlive temporary storage |
| `std::jthread`, `stop_token` | Task lifetime and cooperative stop are well-defined | Worker may block indefinitely or ignores cancellation |
| `atomic::wait/notify`, `latch`, `barrier`, `semaphore` | Synchronization fits an explicit protocol | Mutex ownership or a simpler message queue is clearer |
| `std::format` / `std::format_string` | Safe literal formatting with type checks | The format text is untrusted or output can be unbounded |
| `std::source_location` | Structured diagnostics on a trusted boundary | Logs might expose confidential code/build paths |
| `std::bit_cast`, `std::endian` | Object-representation operations meet size/type constraints | Used as a substitute for validating wire protocols |
| `std::midpoint`, `std::in_range` | Prevent overflow in midpoint and checked type narrowing | Changing numeric meaning without a requirement |
| `<=>`/default comparisons | Structural value types require consistent comparisons | Domain comparisons/order differ from member order |
| `consteval`, `constinit` | A true compile-time guarantee or static initialization constraint | Used decoratively, confusing runtime policy |
| `char8_t` | UTF-8 code-unit representation matters | Assumes UTF-8 validation/transcoding happens automatically |

**Correct narrowing guard:**

```cpp
if (!std::in_range<std::uint16_t>(untrustedPort)) {
    return std::unexpected(ParseError::OutOfRange);
}
const auto port = static_cast<std::uint16_t>(untrustedPort);
```

Use `std::ssize` when signed indexing matches the algorithm and conversions
are deliberate. Defaulted `<=>` reflects structural member order, not all
domain comparison semantics.

## C++23: Focused New Capabilities

| Facility | Use case | Specific hazard/limit |
|---|---|---|
| `std::expected` and its monadic operations | Structured recoverable errors | The caller must consume/propagate errors |
| `std::generator` | Lazy synchronous sequence iteration | Coroutine frame and borrowed references must outlive iteration |
| `std::mdspan` | Non-owning multidimensional storage | Invalid extents, layout, lifetime and unchecked access |
| `std::out_ptr`, `std::inout_ptr` | Adopt resources from C APIs | Exact release function, deleter and reset semantics |
| `std::start_lifetime_as` | Audited implicit-lifetime objects in raw storage | Alignment, representation and live storage are not optional |
| `std::reference_constructs_from_temporary` / `reference_converts_from_temporary` | Reject certain dangling reference wrappers | Traits do not detect every lifetime hazard |
| `std::move_only_function` | Type-erased callable needs move-only closure | Must not invoke an empty wrapper; ownership still matters |
| `std::flat_map`/`std::flat_set` | Sorted small/mostly-static collections with locality benefits | Insertion/erase invalidates iterators/references differently from node maps |
| `std::byteswap` | Explicit integral byte-order conversion | Does not by itself parse or validate protocol layout |
| `std::stacktrace` | Scoped diagnostics with privacy controls | Costs and data disclosure; library support can lag |
| `std::print`/`std::println` | Ordinary project output as `SYN-023` requires | Logging and formatting are not escaping/secret redaction |
| Deducing `this` (explicit object parameter) | Ref-qualified generic member logic becomes demonstrably simpler | Mechanical syntax churn and incompatible compilers |
| `std::to_underlying` | Explicit enum representation at interfaces | Unvalidated deserialization of arbitrary enum values |

**Move-only callback:**

```cpp
auto resource = std::make_unique<Job>();
std::move_only_function<void()> task =
    [owned = std::move(resource)]() { owned->run(); };
if (task) {
    task();
}
```

Do not choose a new abstraction just to avoid a short, readable function.

## C++26: Security-Relevant Additions (Feature-Gated)

| Facility | Potential value | Do **not** assume |
|---|---|---|
| `ckd_add`/`ckd_sub`/`ckd_mul` | Detect overflow before allocation, indexing and arithmetic | Wrapped output is safe when overflow is reported |
| `std::span::at` and `std::mdspan::at` | Explicit checked indexed access | Invalid source pointers/extents become valid |
| `std::saturating_add`/`sub`/`mul`/`div`/`cast` | Defined clamped numeric results where saturation is intentional | Overflow is reported to a caller like checked `ckd_*` (it is not) |
| `std::execution` sender/receiver and async scopes | Structured, composable async work with value/error/stopped channels | Operation-state lifetime, synchronization or cancellation manages itself |
| Contracts (`pre`, `post`, `contract_assert`, `<contracts>`) | Document/test programmer invariants | They run in every build or can reject untrusted requests |
| Standard library hardening | Selected precondition diagnostics/termination | All STLs check every index or recover from violations |
| `std::inplace_vector` | Embedded, fixed-capacity contiguous storage | Growth is unlimited; excess elements need explicit handling |
| `std::hive` | Stable references to surviving elements amid insertion/erasure | Erased-element references remain valid or iteration is contiguous |
| `std::function_ref` | Lightweight **non-owning** synchronous callable parameter | Callable lifetime survives storage or asynchronous invocation |
| `std::copyable_function` | Owning type-erased callable with qualified signatures | Copying/allocating is always efficient |
| `std::dynamic_format` (formerly `runtime_format`) | Explicitly permitted runtime formatting | User input is an inherently trusted format string |
| `<hazard_pointer>` and `<rcu>` | Advanced audited lock-free reclamation | They eliminate synchronization, reclamation, or ABA responsibilities |
| `<simd>` and `<linalg>` | Measured vector/matrix work on supported platforms | Performance, portability, alignment or numeric stability is automatic |
| `<text_encoding>` | Identify encoding information | Arbitrary input is validated or transcoded by naming encoding |
| `<meta>` (reflection) | Reduced manually duplicated metadata | Availability, generated code safety or ABI compatibility is universal |

**C++26 capacity check:**

```cpp
// Only if <inplace_vector> is implemented on the target.
std::inplace_vector<int, 8> pending {};
if (pending.size() >= pending.capacity()) {
    return std::unexpected(QueueError::Full);
}
pending.push_back(value);
```

`std::inplace_vector` capacity is compile-time fixed; exceeding it is not
equivalent to adding memory. Review storage size if large `N` is placed on
the stack. `std::hive` reuses erased storage but does not preserve pointers
to erased objects. `std::function_ref` inherits callable lifetime hazards
from any other non-owning view.

**Dynamic formatting caution:** modern cppreference documents a C++26
rename from `std::runtime_format` to `std::dynamic_format`. Do not hardcode
either spelling without checking the actual toolchain and feature test
macro. Static literal format templates remain the preferred default.

**Async execution caution:** C++26 `std::execution` in `<execution>` includes
sender/receiver operation states. A started operation state's address must
remain stable and it must stay alive until completion. Handle all three
completion channels (`value`, `error`, `stopped`) and verify
`__cpp_lib_senders` availability. A sender description is not automatically
started, and cancellation/ownership are explicit system decisions.

**Saturation caution:** cppreference now uses `std::saturating_add` etc.;
older examples may use `std::add_sat`. Probe the actual `<numeric>` API and
never saturate security-critical allocation sizes silently.

**Concurrency caution:** hazard pointers and RCU may prevent specific
reclamation hazards when correctly used, but they are *not* generic
thread-safety wrappers. Require specialist design, stress tests and
measured justification before adopting.

## FEAT-002 — Containers And Iterator Stability

Choose `std::vector`, `std::deque`, node-based containers,
`std::flat_map`, `std::inplace_vector` or `std::hive` according to:
owning lifetime, insertion patterns, iterator/reference invalidation,
exception guarantees, memory budget and lookup complexity. Replacing
containers in existing code without examining invalidation is forbidden.
Use `std::ranges::to` (C++23) when materializing a lazy range is necessary
to establish ownership, and verify the target library supports it.

## FEAT-003 — Representation, Interop And Diagnostics

For binary I/O, write an explicit wire contract for endianness, alignment,
framing, UTF-8 validity, length, and version. For C handles, pair acquisition
with matching release. For runtime format strings or stack traces, protect
privacy and restrict unbounded output. New syntax is not a security proof.

## FEAT-004 — Performance And Complexity Evidence

Adopt new containers, SIMD, ranges or algorithms only with clear costs,
representative workloads and a *measured* benefit when performance is the
motivation. Correctness/clarity wins when a feature offers no demonstrated
advantage. Explicitly document complexity regressions and compatibility
trade-offs.

## FEAT-005 — Removed And Deprecated Facilities

C++26 removes or changes certain legacy surfaces, including `<codecvt>`,
`<strstream>`, and legacy `std::string::reserve()` overloads.
Do not propagate removed APIs into newly generated code. Where existing
compatibility boundaries need migration, identify the precise API,
supported toolchains, correct replacement and tests.

## Source Checklist

- [C++20 overview](https://en.cppreference.com/cpp/20)
- [C++23 overview](https://en.cppreference.com/cpp/23)
- [C++26 overview and support tables](https://en.cppreference.com/cpp/26)
- [C++ compiler support](https://en.cppreference.com/cpp/compiler_support)
- [Modern standard library headers](https://en.cppreference.com/cpp/standard_library)
- [Move-only function](https://en.cppreference.com/cpp/utility/functional/move_only_function)
- [Non-owning C++26 function_ref](https://en.cppreference.com/cpp/utility/functional/function_ref)
- [C++26 inplace_vector](https://en.cppreference.com/cpp/container/inplace_vector)
- [C++26 hive](https://en.cppreference.com/cpp/container/hive)
- [C++26 dynamic format](https://en.cppreference.com/cpp/utility/format/dynamic_format)
- [C++26 saturation arithmetic](https://en.cppreference.com/cpp/numeric/add_sat)
- [C++26 execution](https://en.cppreference.com/cpp/execution)
- [C++ Core Guidelines](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines)
