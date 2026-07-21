---
description: Add a documented and tested modern C++ module.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Add Module

Read `AGENTS.md`, `docs/agent/ARCHITECTURE.md`, `docs/agent/MODULES.md`, and
`docs/agent/NAMING.md`, and `docs/agent/SYNTAX_AND_STYLE.md`. Define one owned
responsibility, choose a dotted lowercase module identity, separate `.cppm`
declarations from `.cpp` implementation, use `import std` or minimal
global-module-fragment standard headers according to the target mode, register
the module file set, and keep import-std detection two-phase: verified gate and
metadata before `project()`, detected capability and `CXX_MODULE_STD` selection
afterward. Add public-behavior tests, then
configure, build, test, and report exact evidence.
