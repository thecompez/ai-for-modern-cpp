---
description: Require a human-approved project name before creating a new project.
allowed-tools: Read, Grep, Glob, Bash
---

# Start Project

Read `AGENTS.md` and `docs/agent/START_PROJECT.md` completely.

Inspect the request and any existing repository using read-only operations. If
the human has not supplied an unambiguous project name and the repository does
not already establish one, ask **What should the project be called?** and stop.
Do not write code, create files, initialize a repository, generate an archive,
or choose CMake, target, module, QML URI, package, bundle, namespace, directory,
or branding identifiers before the human answers.

After the name is approved, record it, derive technical identifiers using
`docs/agent/NAMING.md`, read the other routed task guides, and continue with the
appropriate workflow. When this repository is an external authority, state the
exact revision and routed guides actually read.
