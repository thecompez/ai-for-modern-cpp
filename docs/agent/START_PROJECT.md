# Start Project Gate

Read this guide before any other task guide when a request creates a new
product, application, service, library, tool, repository, or turns an idea into
an implementation. The gate preserves human ownership of the product identity
and prevents guessed names from leaking into technical identifiers.

## Blocking Decision

Use this decision in order:

1. Inspect the request and, when one exists, the repository using read-only
   operations.
2. If the human supplied one unambiguous project name, record it and continue.
3. If an existing repository already has an established product name, use it
   and continue unless the request explicitly asks for a rename.
4. Otherwise ask one blocking question: **What should the project be called?**
5. Wait for the answer. Do not create code, project files, build files,
   archives, or technical identifiers while waiting.

Requirements discussion and read-only discovery may continue before the name
is known. Implementation planning that commits to identifiers, directory
names, namespaces, QML URIs, package identities, or branding may not.

## After The Human Names The Project

Record the approved display name, then derive technical identities consistently
with `docs/agent/NAMING.md`. If the mapping is not obvious, show it before
implementation:

| Identity | Example derived from an approved name |
|---|---|
| Display name | The exact human-approved product name |
| CMake project | A stable underscore-separated identifier |
| Executable target | A stable target name appropriate to the platform |
| C++ module prefix | Dotted lowercase domain identity |
| QML URI | PascalCase dotted identity |
| Package or bundle ID | Reverse-domain identity only when its owner is known |

Do not invent an organization domain for a package or bundle identifier. Ask a
follow-up question only when that missing choice materially affects the
deliverable.

## Already-Named And Existing Work

Do not interrupt an implementation merely to ask for a name when the request
already says, for example, “Create Aurora Notes,” or when the repository's
established name is Aurora Notes. Generic words such as “calculator,” “chat
app,” or “dashboard” describe a product category; they are not necessarily an
approved name unless the human clearly uses them as one.

`MyApp`, `AppName`, and similar placeholders are documentation-only examples.
They MUST NOT silently become the identity of a generated deliverable.

## Using This Repository As External Authority

Before implementation, load the current `AGENTS.md`, this guide, and every
guide selected by the task-routing table. Record the exact commit SHA or other
immutable revision that was read. If the environment can only cite the
repository URL but cannot read the required files or identify the revision,
report the project as blocked rather than claiming compliance.

## Cross-Agent Entry Points

- Codex: invoke `$source-command-start-project`.
- Claude Code: invoke `/start-project`.
- GPT or another agent: use the universal start prompt in the repository
  `README.md`.

Every entry point implements the same gate. Agent-specific commands are
adapters; `INI-001` through `INI-004` in `AGENTS.md` remain authoritative.
