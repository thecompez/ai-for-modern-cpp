# Architecture Decisions For Agents

Use this guide when locating behavior, adding a subsystem, or changing
dependencies. Canonical rules: `ARC-*`, `MOD-*`, and `PLT-*` in `AGENTS.md`.

## First Question: Who Owns The Behavior?

Do not start by choosing a filename. Start by naming the responsibility.

| Responsibility | Typical owner |
|---|---|
| Domain invariant or value | Domain module |
| Application orchestration | Application module |
| Filesystem, network, process, or OS integration | Platform/adapter module |
| Dependency construction and process startup | Executable composition root |
| Verification-only utilities | Test source, never exported production API |

If no owner is clear, the architecture is not understood well enough to edit.

## Dependency Direction

Stable concepts should not depend on volatile mechanisms.

```mermaid
flowchart LR
    Main["Composition root"] --> Application["Application policy"]
    Main --> Adapter["Platform adapter"]
    Adapter --> Application
    Application --> Domain["Domain model"]
```

Domain code must not import platform adapters. Platform adapters implement or
support needs defined by stable application/domain abstractions.

## Module Boundary Test

A module boundary is justified when at least one is true:

- It owns a stable domain concept.
- It isolates a volatile dependency or platform.
- It has a distinct public contract and independent tests.
- It prevents implementation details from leaking across subsystems.

A boundary is suspicious when its only purpose is reducing file length or when
its name is `utils`, `helpers`, `common`, or `misc`.

## Adding A Subsystem

Before creating files, record:

```text
Responsibility:
Public contract:
Owned data and invariants:
Dependencies:
Expected failures:
Platform assumptions:
Tests proving the boundary:
```

Then choose a dotted domain-oriented module name and follow `MODULES.md`.

## Composition Root

`main.cpp` may construct concrete adapters and connect them to stable
application APIs. It should not contain domain algorithms, persistence logic,
or reusable business rules.

## Architectural Smells

- A public module importing an internal platform module.
- Several modules mutating the same global state.
- Cross-module access to private representation through helper functions.
- A module named after a technical grab bag rather than owned behavior.
- Tests requiring unrelated subsystems to validate one invariant.
- Exported APIs added only to make tests reach private implementation.

When a smell is observed, explain the dependency problem before proposing a
new abstraction.
