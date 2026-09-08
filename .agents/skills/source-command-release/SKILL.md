---
name: "source-command-release"
description: "Prepare a release using a strict verification-first workflow."
---

# source-command-release

Use this skill when the user asks to run the migrated source command `release`.
This workflow is always verification level `V4`; resource discipline never
weakens a release gate.

## Command Template

# Release

Use this command to prepare a release.

## Required Checks

1. Read `AGENTS.md`, `docs/agent/EXECUTION_DISCIPLINE.md`, and
   `docs/agent/TESTING_AND_VERIFICATION.md`.
2. Ensure the working tree is clean.
3. Read the changelog or release notes.
4. Confirm version number.
5. Configure a clean build with every requested default product surface enabled.
6. Build the full default target, not only a core or test target.
7. Run all tests with zero tests treated as an error and run applicable product
   startup or interaction smoke checks.
8. Confirm the `knowledge_contract` test passes.
9. Record a per-surface verification matrix; any required `NOT VERIFIED`
   surface blocks a final release artifact.
10. For graphical products, review rendered minimum, standard, and wide
   screenshots across relevant appearance/content states and record the visual
   acceptance matrix. Visible alignment, overflow, density, or detail defects
   block final release.
11. For Qt Quick products, run strict QML lint with zero project warnings and a
    warning-fatal interaction smoke under the selected Controls style. It must
    reach explicit readiness and instantiate primary-path lazy controls;
    invalid properties, unsupported customization, binding loops, missing-font
    warnings, clipping, and truncated primary actions block release.
12. Record the Qt version, effective style, lint/runtime warning counts, and
    lazy components exercised by the smoke flow.
13. For generated Qt projects, verify deterministic resource aliases and
    separate QML/runtime output roots; record the linked target, `qmldir`, and
    `.qmltypes` paths after the final link.
14. Prepare release notes.
15. Ask for explicit human approval before tagging or publishing.

Do not create tags or publish artifacts without explicit approval.

When application icons or in-application brand marks are in scope, apply `docs/agent/APP_ICONS_AND_BRANDING.md`; any required unverified packaging/icon surface remains `NOT VERIFIED`.
