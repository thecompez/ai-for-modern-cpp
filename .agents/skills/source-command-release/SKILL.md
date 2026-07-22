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
4. Configure a clean build with every requested default product surface enabled.
5. Build the full default target, not only a core or test target.
6. Run all tests with zero tests treated as an error and run applicable product
   startup or interaction smoke checks.
7. Confirm the `knowledge_contract` test passes.
8. Record a per-surface verification matrix; any required `NOT VERIFIED`
   surface blocks a final release artifact.
9. For graphical products, review rendered minimum, standard, and wide
   screenshots across relevant appearance/content states and record the visual
   acceptance matrix. Visible alignment, overflow, density, or detail defects
   block final release.
10. For Qt Quick products, run strict QML lint with zero project warnings and a
    warning-fatal interaction smoke under the selected Controls style. It must
    reach explicit readiness and instantiate primary-path lazy controls;
    invalid properties, unsupported customization, binding loops, missing-font
    warnings, clipping, and truncated primary actions block release.
11. Record the Qt version, effective style, lint/runtime warning counts, and
    lazy components exercised by the smoke flow.
12. Prepare release notes.
13. Ask for explicit human approval before tagging or publishing.

Do not create tags or publish artifacts without explicit approval.
