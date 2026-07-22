---
description: Add a documented and tested modern C++ module.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Add Module

Read `AGENTS.md`, `docs/agent/ARCHITECTURE.md`, `docs/agent/MODULES.md`, and
`docs/agent/NAMING.md`, and `docs/agent/SYNTAX_AND_STYLE.md`. Define one owned
responsibility, choose a dotted lowercase module identity, separate `.cppm`
declarations from `.cpp` implementation, include minimal standard headers in
the global module fragment, register the module file set, and enable target
module scanning. Do not use experimental standard-library modules. Add
public-behavior tests, then
configure, build, test, and report exact evidence.
