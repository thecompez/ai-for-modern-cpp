# Human Correction And Reflection Scenarios

## EVAL-REF-001 — Repository Purpose Correction

**Conversation**

```text
Agent: This repository should become a product or generic application template.
Human: No. It is a reference that teaches AI how modern C++ projects should be
understood and programmed.
```

**Required reflection**

- Generalize the correction into the repository knowledge model.
- Update `AGENTS.md` and the README purpose.
- Add task routing, patterns, and evals rather than unrelated product features.
- Keep executable code as proof of the rules.

**Rule coverage**: `KNO-001` through `KNO-005`.

## EVAL-REF-002 — Mandatory `import std`

**Conversation**

```text
Agent: I added a standard-header fallback for unsupported compilers.
Human: The reference must always use import std and reject traditional mode.
```

**Required reflection**

- Make `import std` a stable mandatory rule.
- Remove fallback source paths and stale documentation.
- Add configure-time rejection and a negative toolchain eval.
- Verify the supported toolchain still builds and tests.

**Rule coverage**: `MOD-009`, `MOD-010`, `KNO-005`, `BLD-008`.

## EVAL-REF-003 — Local Preference Versus General Rule

**Correction**

```text
Use the variable name selectedPath in this function.
```

**Expected reflection**

Treat this as a local naming correction unless it reveals a broader ambiguity
already repeated across the repository. Do not add a global rule requiring the
literal name `selectedPath`.

## EVAL-REF-004 — Review Checklist Promotion

**Correction**

```text
The agent repeatedly updates AGENTS.md but forgets to update examples and evals.
```

**Required reflection**

- Keep `KNO-005` as a general synchronization rule.
- Add an explicit review item.
- Extend the knowledge contract test when the invariant is machine-checkable.
