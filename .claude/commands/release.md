---
description: Prepare a release using a strict verification-first workflow.
allowed-tools: Read, Edit, Bash, Grep, Glob
---

# Release

Use this command to prepare a release.

## Required Checks

1. Ensure the working tree is clean.
2. Read the changelog or release notes.
3. Confirm version number.
4. Configure a clean build with every requested default product surface enabled.
5. Build the full default target, not only a core or test target.
6. Run all tests with zero tests treated as an error and applicable product
   startup or interaction smoke checks.
7. Confirm the `knowledge_contract` test passes.
8. Record a per-surface verification matrix; any required `NOT VERIFIED`
   surface blocks a final release artifact.
9. Prepare release notes.
10. Ask for explicit human approval before tagging or publishing.

Do not create tags or publish artifacts without explicit approval.
