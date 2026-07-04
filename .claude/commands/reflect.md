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
4. If it is general, update `AGENTS.md`.
5. If it is a review checklist item, update `docs/REVIEW.md`.
6. Do not add noisy or overly specific rules.
7. Keep the rule short, enforceable, and practical.

## Output

Summarize:

- What was learned.
- Which file was updated.
- Why the rule is general enough to keep.
