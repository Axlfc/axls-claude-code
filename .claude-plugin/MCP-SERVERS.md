# MCP Servers Included

This plugin includes 3 pre-configured MCP servers that enhance Claude Code's capabilities.

## Included Servers

### 1. **Context7** (`@upstash/context7-mcp`)
**Purpose**: Access up-to-date, version-specific documentation for any library

**Usage**: Just mention "use context7" in your prompt when you need current library documentation

**Benefits**:
- Always up-to-date docs
- Version-specific information
- Works with thousands of libraries
- No manual searching required

## Servers Not Included (Not Yet Available)

The following servers were requested but don't have official MCP implementations yet:

- **chrome-devtools** - No official MCP server found
- **stripe** - No official MCP server found (as of Oct 2025)
- **vercel** - No official MCP server found

## Using MCP Servers

After installing this plugin:

1. **Automatic Activation**: MCP servers start automatically when you use the plugin
2. **Restart Required**: Restart Claude Code after plugin installation
3. **Tool Access**: MCP tools appear in Claude's available tools list

## Adding More MCP Servers

You can add custom MCP servers to your local `.claude/.mcp.json`:

```json
{
  "server-name": {
    "command": "npx",
    "args": ["-y", "package-name"],
    "env": {
      "API_KEY": "your-key"
    }
  }
}
```

## Additional Recommended MCP Servers

### GitHub MCP
**Purpose:** Interact with GitHub repositories, issues, and pull requests

**Installation:**
```json
{
  "github": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-github"],
    "env": {
      "GITHUB_TOKEN": "your_github_personal_access_token"
    }
  }
}
```

**Use Cases:**
- Create issues programmatically
- Review and comment on PRs
- Search code across repositories
- Manage project boards

**Setup:**
1. Generate GitHub Personal Access Token at https://github.com/settings/tokens
2. Required scopes: `repo`, `read:org`
3. Add to `.mcp.json` (or `.mcp.json.local` for private tokens)

---

### PostgreSQL MCP
**Purpose:** Execute read-only database queries and analyze schemas

**Installation:**
```json
{
  "postgres": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-postgres"],
    "env": {
      "POSTGRES_CONNECTION_STRING": "postgresql://user:pass@localhost:5432/dbname"
    }
  }
}
```

**Use Cases:**
- Execute SELECT queries
- Analyze table schemas
- Generate migration suggestions
- Explain query plans

**Security:**
- ⚠️ Only use read-only database users
- ⚠️ Never expose production credentials
- ✅ Use connection string from environment variable

---

### Docker MCP
**Purpose:** Manage Docker containers and inspect Docker Compose services

**Installation:**
```json
{
  "docker": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-docker"],
    "env": {
      "DOCKER_HOST": "unix:///var/run/docker.sock"
    }
  }
}
```

**Use Cases:**
- List running containers
- Inspect container logs
- Check container health
- View Docker Compose services

**Requirements:**
- Docker daemon running
- User has Docker permissions

---

## Configuration Methods

### Method 1: Global Configuration
Create `~/.config/claude-code/.mcp.json`:
```json
{
  "github": { ... },
  "postgres": { ... },
  "docker": { ... }
}
```

### Method 2: Project-Level Configuration
Create `.mcp.json` in project root:
```json
{
  "postgres": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-postgres"],
    "env": {
      "POSTGRES_CONNECTION_STRING": "${POSTGRES_URL}"
    }
  }
}
```

**Note:** Use `.mcp.json.local` for sensitive credentials (add to `.gitignore`)

### Method 3: Environment Variables
```bash
# Add to ~/.bashrc or ~/.zshrc
export GITHUB_TOKEN="your_token"
export POSTGRES_URL="postgresql://..."

# Then reference in .mcp.json
{
  "github": {
    "env": {
      "GITHUB_TOKEN": "${GITHUB_TOKEN}"
    }
  }
}
```

---

## Security Best Practices

1. **Never Commit Credentials:**
   - Add `.mcp.json.local` to `.gitignore`
   - Use environment variables
   - Use secret management tools

2. **Use Least Privilege:**
   - Read-only database users
   - Minimal GitHub token scopes
   - Docker with limited permissions

3. **Rotate Tokens Regularly:**
   - GitHub tokens every 90 days
   - Database passwords quarterly
   - Revoke unused tokens immediately

---

## Troubleshooting

**MCP servers not loading?**
1. Restart Claude Code
2. Check that npm/npx is installed
3. Verify network connection (MCP servers download on first use)

**Performance issues?**
- MCP servers run on-demand
- First use may be slower (package download)
- Subsequent uses are fast

## Learn More

- Official MCP Documentation: https://modelcontextprotocol.io
- Claude Code MCP Guide: https://docs.claude.com/en/docs/claude-code/mcp
- MCP Server Directory: https://mcpcat.io
