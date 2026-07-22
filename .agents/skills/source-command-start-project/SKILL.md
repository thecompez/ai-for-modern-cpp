---
name: source-command-start-project
description: Enforce the human-approved project-name gate before creating a new product, application, service, library, tool, repository, or implementing an idea. Use when starting new project work or when another workflow is about to generate a project.
---

# Start Project

Read `AGENTS.md` and `docs/agent/START_PROJECT.md` completely before taking any
project-creation action.

## Required Process

1. Inspect the request and any existing repository using read-only operations.
2. Determine whether the human supplied an unambiguous project name or the
   existing repository already establishes one.
3. If no name is established, ask: **What should the project be called?**
4. Immediately stop and wait. Do not write code, create files, initialize a
   repository, generate an archive, or choose technical identifiers while the
   name is unresolved.
5. After the human supplies the name, record the approved display name and
   derive technical identifiers according to `docs/agent/NAMING.md`.
6. Read the remaining guides selected by the task-routing table and continue
   with the appropriate implementation or design workflow.
7. When this repository is an external authority, report the exact revision
   and routed guides actually read before implementation.

## Output Contract

Before implementation, state the approved project name and the repository
revision used as engineering authority. If the name is missing, the only final
result of this workflow is the blocking name question; implementation has not
started.
