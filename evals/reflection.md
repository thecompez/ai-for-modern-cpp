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

## EVAL-REF-005 — Durable Personal Naming Convention

**Conversation**

```text
Agent: enum class ErrorCode { empty_expression }; std::string value_;
Human: I consistently require PascalCase enumerators and m_-prefixed members.
```

**Required reflection**

- Recognize a repeated repository-wide convention rather than a local rename.
- Define concise naming and syntax rules.
- Add correct/incorrect examples and review coverage.
- Add an eval and enforce the executable proof where practical.

**Rule coverage**: `KNO-004`, `KNO-005`, `NAM-003`, `NAM-005`, `SYN-004`.

## EVAL-REF-006 — Domain-Specific Example In A General Guide

**Conversation**

```text
Agent: I reused one sample application's type names throughout the general Qt
Quick guide.
Human: This repository teaches project engineering, not one application domain.
Use neutral placeholders such as MyApp or AppName.
```

**Required reflection**

- Replace domain-specific names in canonical guides with neutral placeholders.
- Keep concrete domains only where an eval intentionally tests that scenario.
- Add review and machine-checkable coverage to prevent canonical guides from
  drifting back toward one example application.

**Rule coverage**: `KNO-004`, `KNO-005`, `DOC-008`.

## EVAL-REF-007 — CLI-Only Default For An Interactive Application

**Conversation**

```text
Agent: The interface was unspecified, so I delivered only a CLI program.
Human: User-facing interactive applications should have a Qt Quick primary UI;
a CLI may exist as a secondary adapter.
```

**Required reflection**

- Generalize the correction into an interaction-surface selection rule.
- Preserve explicit CLI, service, library, daemon, and headless scopes.
- Require Qt Quick as the primary surface for otherwise unspecified
  user-facing interactive applications.
- Keep an optional CLI thin and connected to shared application/domain modules.
- Synchronize routing, the Qt guide, architecture, patterns, review, evals, and
  machine-checkable knowledge assertions.

**Rule coverage**: `KNO-004`, `KNO-005`, `GUI-015`, `GUI-016`, `ARC-002`.
