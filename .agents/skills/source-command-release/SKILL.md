---
name: "source-command-release"
description: "Prepare a release using a strict verification-first workflow."
---

# source-command-release

Use this skill when the user asks to run the migrated source command `release`.

## Command Template

# Release

Use this command to prepare a release.

## Required Checks

1. Ensure the working tree is clean.
2. Read the changelog or release notes.
3. Confirm version number.
4. Build the project.
5. Run tests.
6. Confirm the `knowledge_contract` test passes.
7. Prepare release notes.
8. Ask for explicit human approval before tagging or publishing.

Do not create tags or publish artifacts without explicit approval.
