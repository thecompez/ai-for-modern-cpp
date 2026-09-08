# Agent Knowledge Map

This directory turns the canonical rules in `AGENTS.md` into task-specific
engineering guidance. It exists to improve agent decisions, not to duplicate
policy.

## Truth Hierarchy

```text
Higher-priority human and platform instructions
    ↓
AGENTS.md — canonical repository policy
    ↓
docs/agent/* — task-specific interpretation and decision support
    ↓
docs/agent/PATTERNS.md and executable source — examples and proof
    ↓
evals/* — behavior assessment
```

If a guide conflicts with `AGENTS.md`, follow `AGENTS.md`, report the conflict,
and update the guide in the same change when authorized.

## Routing Map

| Question | Read |
|---|---|
| May I start creating this new project yet? | `START_PROJECT.md` before every other guide |
| Where should this behavior live? | `ARCHITECTURE.md` |
| Is this declaration or implementation? | `MODULES.md` |
| What should this symbol be called? | `NAMING.md` |
| Which C++ syntax and style shape is required? | `SYNTAX_AND_STYLE.md` |
| What should the public contract expose? | `API_DESIGN.md` |
| Is this `expected`, an exception, or RAII? | `ERRORS_AND_RESOURCES.md` |
| Where does OS-specific code belong? | `PLATFORM_BOUNDARIES.md` |
| How should application icons and in-application brand marks be designed, generated, packaged, and verified? | `APP_ICONS_AND_BRANDING.md`, then `PLATFORM_BOUNDARIES.md` and `QT_QUICK_UI.md` when applicable |
| What interface should an unspecified interactive application use? | `QT_QUICK_UI.md`, then `ARCHITECTURE.md` |
| How should a Qt interface be designed and implemented? | `QT_QUICK_UI.md` |
| How should modules and standard headers be configured? | `CMAKE_AND_TOOLCHAINS.md`, then `COMMON_FAILURES.md` |
| What CMake baseline should a generated Qt Quick project start from? | `PROJECT_CMAKE_BASELINE.md`, then `CMAKE_AND_TOOLCHAINS.md` and `QT_QUICK_UI.md` |
| How much should I inspect, delegate, build, or retest? | `EXECUTION_DISCIPLINE.md` |
| What and how should I test? | `TESTING_AND_VERIFICATION.md` |
| What does approved code look like? | `PATTERNS.md` |

## Decision Workflow

Before editing:

1. For a new product or project, pass the project-name gate in
   `START_PROJECT.md`; if the name is missing, ask and stop before writing.
2. Identify the requested outcome.
3. Inspect the working tree and current diff.
4. Identify the owning subsystem.
5. Select the guides from the routing map.
6. Read the selected guides completely.
7. Inspect the relevant source, CMake target, and tests.
8. State any assumption that materially affects the design.

After editing:

1. Classify the change as `V0` through `V4`.
2. Reuse a compatible build tree for incremental `V1`/`V2` verification.
3. Build the smallest affected production surface and run relevant tests/lint/smoke.
4. After a failure, rerun from the earliest stage invalidated by the fix.
5. Escalate to structural or clean full verification only when the changed
   surface or final claim requires it.
6. Run the knowledge contract for policy or documentation changes.
7. Inspect the final diff and `git diff --check` when git metadata is available.
8. Report exact evidence, selected verification level, and limitations, then stop.

## Knowledge Maintenance

A durable correction belongs in one or more of these surfaces:

| Correction type | Durable destination |
|---|---|
| Repository-wide invariant | `AGENTS.md` |
| Task-specific reasoning | Relevant guide in this directory |
| Reviewable condition | `docs/REVIEW.md` |
| Common good/bad shape | `PATTERNS.md` |
| Reproducible behavioral challenge | `evals/` |
| Enforceable repository invariant | `tests/knowledge_contract.cmake` |

Do not promote incidental preferences or one-off fixes into global rules.
