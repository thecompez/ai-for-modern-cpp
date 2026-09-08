# Execution And Resource Discipline

Use this guide to keep agentic engineering focused, economical, and verifiable.
Canonical rules: `EFF-*`, `SCP-*`, and `VER-013` through `VER-018`.

The objective is not to minimize verification. It is to spend investigation,
context, commands, and parallelism only where they increase confidence in the
requested change.

## Default Execution Shape

```text
One agent
  -> targeted repository search
  -> owning subsystem
  -> routed guides only
  -> smallest coherent edit
  -> adaptive verification
  -> final diff
  -> exact report
  -> stop
```

A routine bug fix, UI adjustment, focused refactor, or build diagnosis should not
become a repository-wide audit merely because the agent has permission to read
or run more tools.

## Single-Agent Default

Use one agent unless the task contains genuinely independent workstreams.
Parallel delegation is justified only when all of these are true:

1. The scopes can be described independently without overlapping ownership.
2. Each scope has a bounded file/subsystem surface and a concrete question.
3. Results can be reconciled without repeating the same repository discovery.
4. Parallel execution materially reduces completion time or resolves distinct
   platform/toolchain evidence that one environment cannot provide.

Good delegation examples:

- independent macOS and Windows platform adapters after the shared contract is
  already established;
- two unrelated GitHub issues explicitly requested together;
- an isolated security review while another agent performs a separate migration
  plan, when both are explicitly requested.

Bad delegation examples:

- separate `review startup`, `review routing`, `review UI`, and `review tests`
  workers for one small diff;
- multiple agents reading the same `AGENTS.md`, guides, and source tree;
- recursive reviewer-of-reviewer chains;
- launching a subagent merely to confirm a conclusion already supported by
  local evidence.

## Discovery Budget

Discovery is question-driven. Prefer this order:

1. Inspect the current diff and working tree.
2. Search for the symbol, component, target, issue identifier, or error text.
3. Open the owning source and directly coupled tests/configuration.
4. Route to only the guides required by the touched concerns.
5. Stop discovery when ownership, contract, change surface, and verification
   path are known.

Do not recursively browse directories because they exist. Exclude generated
sources, build directories, vendored dependencies, caches, package outputs, and
third-party trees unless a concrete error points there.

Within one task, do not reread an unchanged guide or large source file unless a
new question requires context that was not already obtained.

## External Research

Repository-local evidence wins for repository behavior. Use external research
only for facts that can change outside the repository, such as:

- current framework/toolchain documentation;
- an external API or protocol contract;
- platform behavior not documented in the repository;
- a dependency regression or compatibility question that local evidence cannot
  resolve.

Do not search the web for ordinary symbol discovery, internal architecture,
local tests, or code that is already present in the repository.

## Build-Tree Reuse

A clean build is evidence, but it is not the only valid evidence.

Reuse a configured build tree when all relevant inputs remain compatible:

- same compiler and standard library;
- same generator;
- same CMake/toolchain configuration;
- no change that invalidates module scanning or target topology;
- requested product surface is enabled in that tree.

Use a fresh or clean configure when changing toolchains, CMake graph inputs,
module topology, generated registration/resource topology, or when performing a
`V4` final gate.

## Failure Rerun Rule

Rerun the earliest stage invalidated by the fix, not the entire pipeline by
habit.

| Failure/fix | Resume from |
|---|---|
| C++ source compile error; CMake graph unchanged | affected build target |
| QML syntax/property/layout fix; registration graph unchanged | relevant lint/affected Qt target, then smoke |
| Test expectation/body only | affected target if needed, then affected tests |
| Link dependency or target registration change | configure if graph changed, then affected build |
| CMake/toolchain/module-scanning change | configure |
| Release/final artifact | clean `V4` gate |

If a later failure reveals that the assumed scope was too narrow, escalate the
verification level and record why.

## Stop Conditions

Stop when all are true:

- requested behavior is implemented;
- no unrelated human work was disturbed;
- the selected verification gate passed, or unavailable stages are explicitly
  `NOT VERIFIED`;
- the final diff was inspected;
- known limitations are reported.

Do not continue into unrelated cleanup, redesign, benchmarking, documentation,
web research, or additional review merely because time or tool access remains.
