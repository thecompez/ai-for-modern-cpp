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

## EVAL-REF-002 — Preserve Modules Without Importing The Standard Library Module

**Conversation**

```text
Agent: Standard-library modules are unreliable here, so I will replace all
modules with headers.
Human: Keep project modules, remove import std entirely, and use standard
headers in global module fragments.
```

**Required reflection**

- Keep `.cppm`, project module imports, and `CXX_MODULES` registration mandatory.
- Forbid experimental `import std`, its CMake gates, and metadata setup.
- Use `module;` global fragments without creating project-owned headers or
  duplicate source trees.
- Keep one deterministic build path rather than automatic and forced modes.
- Synchronize toolchain diagnostics, CI, patterns, evals, and contract tests.

**Rule coverage**: `MOD-009` through `MOD-012`, `KNO-005`, `BLD-006` through
`BLD-009`, and `BLD-013`.

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

## EVAL-REF-008 — Mechanical Style And Generic UI Corrections

**Conversation**

```text
Agent: I forced auto ... -> ReturnType everywhere, created a top-level qml/
bucket, reused the same decorative card layout, and wrote console output with
std::cout.
Human: Prefer readable return declarations, a cohesive ui/ boundary,
product-specific UX, and current standard formatted output.
```

**Required reflection**

- Generalize the correction into readable syntax selection rather than a ban
  on every trailing return type.
- Require `std::print`/`std::println` for ordinary new formatted output while
  preserving explicitly justified stream-only boundaries.
- Describe `ui/` as an architectural presentation boundary and avoid empty
  ceremonial subdirectories.
- Require audience, task hierarchy, states, affordances, feedback, prevention,
  recovery, and product-specific visual direction before implementation.
- Synchronize canonical rules, guides, patterns, workflows, review checks,
  evals, and machine-checkable assertions.

**Rule coverage**: `KNO-004`, `KNO-005`, `ARC-007`, `SYN-001`, `SYN-023`,
`GUI-017`, and `GUI-018`.

## EVAL-REF-009 — Repeated Generated-Project Module Failure

**Conversation pattern**

```text
Agent: I added experimental standard-library module detection to every generated
project.
Human: These projects keep failing on gates and metadata. Keep project modules,
but always use standard headers and remove import std.
```

**Required reflection**

- Promote the repeated failure into a standard-header-only policy, not a
  project-name-specific patch.
- Remove gates, metadata lookup, capability probes, mode switches, and
  `CXX_MODULE_STD` properties.
- Preserve `.cppm`, project imports, module file sets, and scanning.
- Classify missing generated QML metadata after a failed Generate step as a
  cascading symptom.
- Add guarded QTP0004 guidance for QML subdirectories without falsifying the
  project's minimum Qt version.
- Keep one combined generated-project CMake baseline so agents do not join
  correct fragments in an invalid order.
- Synchronize canonical rules, toolchain and Qt guides, failure catalog,
  patterns, review checks, workflows, evals, and machine-checkable assertions.

**Rule coverage**: `KNO-004`, `KNO-005`, `MOD-010`, `BLD-006` through
`BLD-014`, `GUI-019`, `VER-002`.

## EVAL-REF-010 — Repeated Nested QML Registration Failure

**Conversation pattern**

```text
Agent: The QML adapter is under src/presentation and qt_add_qml_module lists it.
Human: Generated registration still cannot see the type because it includes the
header by basename.
```

**Required reflection**

- Generalize the correction into a target-local include-path rule for nested
  `QML_ELEMENT` adapter headers.
- Keep the responsibility-oriented presentation directory.
- Forbid editing generated registration sources.
- Update the combined project baseline, Qt guide, common failures, review,
  evals, and knowledge contract.

**Rule coverage**: `KNO-004`, `KNO-005`, `GUI-020`, `BLD-014`.

## EVAL-REF-011 — Partial Build Reported As Complete Product

**Conversation pattern**

```text
Agent: Core and headless tests pass. Qt is unavailable, but the final desktop
application archive is ready.
Human: The requested Qt target was never compiled. Every part must be deeply
verified before the final file is delivered.
```

**Required reflection**

- Generalize the correction into claim-scope and final-delivery rules rather
  than a one-project warning.
- Require a clean build with every requested default surface enabled and the
  full default target built.
- Require tests across domain, presentation, QML creation/interaction, and an
  applicable product smoke flow.
- Treat unavailable dependencies as `NOT VERIFIED`, never implicit success.
- Block a ready/final archive until all requested primary surfaces pass.
- Synchronize canonical policy, testing and Qt guides, workflows, review,
  patterns, evals, and the executable knowledge contract.

**Rule coverage**: `KNO-004`, `KNO-005`, `GUI-022`, `TST-007`, `VER-008`,
`VER-009`, `REP-008`.
