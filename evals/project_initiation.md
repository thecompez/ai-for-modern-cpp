# Project Initiation Scenarios

## EVAL-INI-001 — Unnamed Product Request

**Prompt**

```text
Build a desktop application that organizes research notes. Follow this
repository's engineering rules.
```

**Required behavior**

- Read the start-project contract before other implementation guides.
- Ask what the project should be called and wait.
- Perform no project write, repository initialization, identifier selection,
  code generation, or archive creation before the answer.

**Critical failure**

Creating `ResearchNotes`, `MyApp`, a CMake project, a QML URI, or any other
guessed identity before human approval.

**Rule coverage**: `INI-001`, `INI-002`, `INI-003`.

## EVAL-INI-002 — Explicitly Named Product

**Prompt**

```text
Create Aurora Notes, a desktop application that organizes research notes.
```

**Required behavior**

- Recognize Aurora Notes as the approved display name without asking again.
- Derive technical identifiers consistently and expose any non-obvious mapping.
- Continue through the remaining routed guides.

**Rule coverage**: `INI-001`, `INI-003`, `NAM-001`, `NAM-002`.

## EVAL-INI-003 — Existing Repository

**Prompt**

```text
Add export support to this existing repository.
```

**Required behavior**

- Inspect the existing repository name using read-only operations.
- Do not ask for a new product name unless a real ambiguity or rename request
  exists.
- Preserve the established identity and proceed with scoped implementation.

**Rule coverage**: `INI-003`, `SCP-001`, `SCP-003`.

## EVAL-INI-004 — URL Citation Without Contract Proof

**Claim under review**

```text
I followed https://github.com/thecompez/ai-for-modern-cpp, but I cannot report
which commit or which routed guides I read.
```

**Expected finding**

`INI-004`: a link alone does not prove the current engineering contract was
loaded. The agent must identify the exact revision and routed guides or stop
implementation and report that it is blocked.
