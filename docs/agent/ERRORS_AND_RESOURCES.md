# Errors And Resource Ownership

Use this guide for failure modeling, ownership, files, sockets, handles,
threads, locks, timers, and temporary resources. Canonical rules: `ERR-*` and
`RES-*`.

## Failure Decision Table

| Situation | Mechanism |
|---|---|
| Expected parse, lookup, validation, or I/O failure | `std::expected<T, E>` |
| Value may legitimately be absent without an error | `std::optional<T>` |
| Constructor cannot establish its invariant | Exception or validated factory |
| Programmer violated an internal invariant | Assertion, contract, or exception according to subsystem policy |
| Process cannot continue safely | Translate at composition boundary and return failure |

Errors should carry enough structure for the caller to decide what to do. Avoid
logging deep inside reusable modules unless logging is the module's explicit
responsibility.

## `std::expected` Shape

Prefer a meaningful error type over an unexplained string when callers need to
branch on failure.

```cpp
enum class ParseErrorCode {
    EmptyInput,
    InvalidFormat,
};

struct ParseError final {
    ParseErrorCode code;
    std::string message;
};
```

## RAII Ownership

Every acquire operation must have one deterministic owner. Cleanup belongs in
that owner's destructor, not in every caller.

```cpp
class NativeHandle final {
public:
    explicit NativeHandle(void* handle) noexcept;
    ~NativeHandle();

    NativeHandle(const NativeHandle&) = delete;
    auto operator=(const NativeHandle&) -> NativeHandle& = delete;

    NativeHandle(NativeHandle&& other) noexcept;
    auto operator=(NativeHandle&& other) noexcept -> NativeHandle&;

private:
    void* m_handle {};
};
```

The raw representation is acceptable only because it is isolated behind an
ownership abstraction at a low-level boundary.

## Ownership Review Questions

1. Who releases the resource?
2. Can two objects believe they own it?
3. What happens during exceptions or early returns?
4. Are move and copy semantics correct?
5. Is a borrowed view able to outlive its owner?
6. Does asynchronous work retain valid state?

If any answer is unclear, the ownership design is incomplete.
