---
description: Convert repeated human corrections into durable repository agent rules.
allowed-tools: Read, Edit, Bash, Grep, Glob
---

# Reflect

Use this after the human corrected AI-generated work.

## Process

1. Read the current diff.
2. Identify what the human changed.
3. Decide whether the correction is local or a general repository rule.
4. If it is general, update `AGENTS.md` with a short stable rule.
5. Route the lesson to affected guides under `docs/agent/`.
6. Update `docs/REVIEW.md` when the correction is reviewable.
7. Add or update a pattern, eval, and knowledge-contract assertion when useful.
8. Keep executable examples synchronized.
9. Do not add noisy or overly specific rules.

## Output

Summarize:

- What was learned.
- Which file was updated.
- Why the rule is general enough to keep.
- Which knowledge surfaces were synchronized.
