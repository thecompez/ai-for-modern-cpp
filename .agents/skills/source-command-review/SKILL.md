---
name: "source-command-review"
description: "Review a repository change against the modern C++ knowledge contract with bounded discovery."
---

# Review

Use this skill for code review, pre-commit review, or policy conformance review.

## Required Process

1. Read `AGENTS.md`, `docs/agent/EXECUTION_DISCIPLINE.md`, and `docs/REVIEW.md`.
2. Inspect the current diff and working tree first.
3. Route only to task guides touched by the diff.
4. Use one reviewer by default; do not fan out routine subsystem reviewers for
   a focused change.
5. Prioritize correctness, safety, ownership, architecture, and whether the
   reported verification level/evidence matches the changed surface.
6. Cite stable rule identifiers for actionable findings.
7. Keep line ranges tight and avoid speculative style comments.
8. State explicitly when there are no actionable findings, then stop.

Do not modify code unless the user also asks to address findings.
