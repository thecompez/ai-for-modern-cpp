---
name: "source-command-review"
description: "Review a repository change against the modern C++ knowledge contract."
---

# Review

Use this skill for code review, pre-commit review, or policy conformance review.

## Required Process

1. Read `AGENTS.md`.
2. Read `docs/REVIEW.md` completely.
3. Inspect the current diff and working tree.
4. Route to every task guide touched by the diff.
5. Prioritize correctness, safety, ownership, architecture, and verification.
6. Cite stable rule identifiers for actionable findings.
7. Keep line ranges tight and avoid speculative style comments.
8. State explicitly when there are no actionable findings.

Do not modify code unless the user also asks to address findings.
