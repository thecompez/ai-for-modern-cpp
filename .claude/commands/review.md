---
description: Review a change against the rule-driven modern C++ contract with bounded discovery.
allowed-tools: Read, Bash, Grep, Glob
---

# Review

Read `AGENTS.md`, `docs/agent/EXECUTION_DISCIPLINE.md`, and `docs/REVIEW.md`.
Inspect the current diff first, then read only task guides touched by that diff.
Use one reviewer by default; do not fan out routine subsystem reviewers for a
focused change. Prioritize correctness, safety, ownership, architecture, and
whether the selected verification level/evidence matches the changed surface.
Cite stable rule identifiers, keep line ranges tight, do not invent findings,
and stop when the bounded review is complete. Do not edit unless asked.
