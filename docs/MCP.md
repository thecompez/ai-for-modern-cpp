# MCP Configuration

This repository includes an example MCP configuration for AI coding agents.

MCP means Model Context Protocol. It is a standard way to connect AI applications to external tools, repositories, file systems, databases, and other context providers.

## Files

```text
.mcp.example.json
docs/MCP.md
```

The repository does not enable MCP servers by default.

Copy the example when you intentionally want to use it:

```bash
cp .mcp.example.json .mcp.json
```

Do not commit `.mcp.json` if it contains local paths, machine-specific settings, tokens, or private endpoints.

## Recommended Safety Model

Use the smallest useful permission set.

Start with read-only tools.

Avoid giving agents broad shell, network, or secret access unless the task requires it.

Recommended order:

```text
1. filesystem-readonly
2. git-local
3. github-readonly
4. project-specific build/test tools
5. write-capable or deployment tools only when explicitly needed
```

## Example Servers

### Filesystem

Allows the agent to inspect project files.

```json
{
  "filesystem-readonly": {
    "command": "npx",
    "args": [
      "-y",
      "@modelcontextprotocol/server-filesystem",
      "."
    ]
  }
}
```

### Git

Allows the agent to inspect repository history and local git state.

```json
{
  "git-local": {
    "command": "npx",
    "args": [
      "-y",
      "@modelcontextprotocol/server-git",
      "--repository",
      "."
    ]
  }
}
```

### GitHub

Allows the agent to inspect GitHub repository data when a token is provided through the environment.

```json
{
  "github-readonly": {
    "command": "npx",
    "args": [
      "-y",
      "@modelcontextprotocol/server-github"
    ],
    "env": {
      "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}"
    }
  }
}
```

## Secret Handling

Never hardcode secrets in MCP config files.

Use environment variables:

```bash
export GITHUB_PERSONAL_ACCESS_TOKEN="..."
```

Do not commit tokens.

Do not commit private MCP endpoints.

Do not grant write access unless the task explicitly needs it.

## Agent Rules

Agents must:

- Read `AGENTS.md` before using MCP tools.
- Use MCP tools only for the requested task.
- Avoid reading unrelated private files.
- Avoid invoking write-capable tools without explicit user intent.
- Report which MCP tools were used in the final summary when relevant.
- Never claim MCP data was inspected unless it was actually inspected.
