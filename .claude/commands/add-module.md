---
description: Add a documented and tested modern C++ module.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Add Module

Read `AGENTS.md`, `docs/agent/EXECUTION_DISCIPLINE.md`,
`docs/agent/ARCHITECTURE.md`, `docs/agent/MODULES.md`, and
`docs/agent/NAMING.md`, and `docs/agent/SYNTAX_AND_STYLE.md`. Define one owned
responsibility, choose a dotted lowercase module identity, separate `.cppm`
declarations from `.cpp` implementation, include minimal standard headers in
the global module fragment, register the module file set, and enable target
module scanning. Do not use experimental standard-library modules. Add
public-behavior tests, then treat the module-topology change as `V3`:
configure as required, build every affected production surface, run relevant
tests, and report exact evidence without unrelated full-project work.
