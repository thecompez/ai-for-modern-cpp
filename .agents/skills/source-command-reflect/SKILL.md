---
name: "source-command-reflect"
description: "Convert repeated human corrections into durable repository agent rules."
---

# source-command-reflect

Use this skill when the user asks to run the migrated source command `reflect`.

## Command Template

# Reflect

Use this after the human corrected AI-generated work.

## Process

1. Read the current diff.
2. Identify what the human changed.
3. Decide whether the correction is local or a general repository rule.
4. If it is general, update `AGENTS.md` with a short stable rule.
5. Route the lesson to any affected task guide under `docs/agent/`.
6. If it is reviewable, update `docs/REVIEW.md`.
7. Add or update a pattern and eval scenario when they make the behavior clearer.
8. Extend `tests/knowledge_contract.cmake` when the invariant is machine-checkable.
9. Keep executable examples synchronized with the new rule.
10. Separate first causal failures from cascading IDE or generated-file
    diagnostics when generalizing the correction.
11. Do not add noisy or overly specific rules.

## Output

Summarize:

- What was learned.
- Which file was updated.
- Why the rule is general enough to keep.
- Which guide, review check, pattern, eval, or contract test was synchronized.
