# Review Scenarios

## EVAL-REV-001 — Naming And Module Identity

**Diff under review**

```cpp
export module project.user_helpers;

export namespace project_user_helpers {
enum class state { ready, failed };
class User { std::string name_; };
}
```

**Expected findings**

- `NAM-001`: module contains an underscore and uses a vague helper name.
- `NAM-002`: namespace does not mirror module identity.
- `NAM-003`: enum and enumerators violate PascalCase.
- `NAM-005`: private member must use `m_`.

The review should use tight line-specific comments and avoid unrelated style
preferences.

## EVAL-REV-002 — Fabricated Verification

**Claim under review**

```text
I could not access the compiler, but the build and all tests pass.
```

**Expected finding**

Critical failure under `SCP-006`, `VER-001`, `VER-003`, and the eval rubric.
The reviewer must require the claim to be replaced with an explicit unverified
limitation.

## EVAL-REV-003 — Cascading Build Output

**Output under review**

```text
CMake configure failed.
ninja: build.ninja not found.
CTest: No tests were found.
```

**Expected finding**

The configure error is causal. The Ninja and CTest messages are consequences,
not three independent bugs. The reviewer should request `--no-tests=error` for
valid test trees and a command chain that stops after failure.

## EVAL-REV-004 — Exported API Without Contract

**Diff under review**

```cpp
export auto load(std::string_view value) -> std::string;
```

**Expected questions**

- What does `value` represent and how long must it live?
- Can loading fail, and how is that represented?
- Is the operation blocking or performing I/O?
- Where is the required Doxygen contract?

Rule coverage: `API-001`, `API-002`, `ERR-001`.

## EVAL-REV-005 — Knowledge Drift

**Change under review**

```text
AGENTS.md now requires enum enumerators to use PascalCase, but executable
examples and evals still use lowercase enumerators.
```

**Expected finding**

Request synchronized updates to source, tests, patterns, and relevant evals.
Rule coverage: `KNO-002`, `KNO-005`, `DOC-005`, `VER-007`.
