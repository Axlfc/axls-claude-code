# Claude Code for Personal Usage

Your AI Employee infrastructure. Build AI systems that do real work in your business.

---

## IMPORTANT: Working Directory

**You MUST open THIS folder directly in VS Code.**

If you cloned this repo into a subfolder, make sure VS Code opens the folder containing this `CLAUDE.md` file at the root — NOT a parent folder.

**Correct:** VS Code opens `axls-claude-code/`  
**Wrong:** VS Code opens a parent folder that contains `axls-claude-code/`

If skills, MCPs, or agents aren't working, this is usually why.

---

## Routing

| When you want to... | Load skill |
|---------------------|------------|
| Create a new skill | `create-skill` |
| Create a new command | `create-command` |
| Create a new agent | `create-agent` |
| Create a new hook | `create-hook` |
| Add or build an MCP | `create-mcp` |
| Search online for MCP servers | `mcp-finder` agent (spawned by create-mcp) |

> 💡 **Special n8n routing**: When building n8n workflows, the system will auto-activate the relevant n8n skills based on your query (e.g., “Build a webhook to Slack” → activates multiple n8n skills).

---

## Output Organization

**Principle:** Never dump files in root. Outputs go in logical folders.

| Output Type | Location | Example |
|-------------|----------|---------|
| Content | `content/[type]/[project]/` | `content/youtube/competitor-analysis/` |
| Research | `research/[topic]/` | `research/ai-tools/` |
| Data | `data/[source]/` | `data/youtube-api/` |
| Exports | `exports/[format]/` | `exports/csv/` |
| n8n Workflows | `workflows/n8n/` | `workflows/n8n/webhook-slack.json` |

**When creating skills that produce output:**
1. Determine what TYPE of output (content, research, data, export, workflow)
2. Create the appropriate folder structure
3. Use descriptive project/topic names
4. Keep related files together

---

## Folder Structure

```
axls-claude-code/
├── CLAUDE.md              # Project memory + rules (this file)
├── .mcp.json              # MCP server connections
│
├── .claude/
│   ├── settings.json      # Permissions and hooks
│   ├── skills/            # Your custom + n8n skills
│   ├── commands/          # Your slash commands
│   └── agents/            # Your subagents
│
├── content/               # Content outputs (videos, posts, etc.)
├── research/              # Research outputs
├── data/                  # Raw or processed data
├── exports/               # Formatted exports (CSV, JSON, etc.)
└── workflows/             # n8n workflow definitions
    └── n8n/               # n8n-specific workflows
```

**Rules live in CLAUDE.md** — this file. Add project-wide guidelines here.

---

## MCP Servers

This project is configured to use:
- **YouTube MCP** – For video research and analytics  
- **Notion MCP** – For saving insights and structured data  
- **n8n-mcp MCP Server** – For building, validating, and deploying n8n workflows

> 🔌 Ensure all MCP servers are running and listed in `.mcp.json`. The n8n-mcp server must be installed and accessible (see [n8n-mcp docs](https://github.com/czlonkowski/n8n-mcp)).

---

## n8n Skills Integration

This project includes **7 expert n8n skills** (from [`czlonkowski/n8n-skills`](https://github.com/czlonkowski/n8n-skills)) that teach Claude how to build production-ready n8n workflows using the **n8n-mcp MCP server**.

### The 7 n8n Skills (auto-activated)

| Skill | Purpose |
|------|--------|
| `n8n-expression-syntax` | Correct use of `{{}}` expressions, `$json.body`, common pitfalls |
| `n8n-mcp-tools-expert` | How to use `search_nodes`, `get_node`, `validate_node`, `n8n_update_partial_workflow`, etc. |
| `n8n-workflow-patterns` | 5 proven patterns: webhook, HTTP API, database, AI, scheduled |
| `n8n-validation-expert` | Interpret & fix validation errors; use `n8n_autofix_workflow` |
| `n8n-node-configuration` | Operation-aware setup (e.g., `sendBody → contentType`) |
| `n8n-code-javascript` | JavaScript in Code nodes (`$input`, `$helpers`, return format) |
| `n8n-code-python` | Python in Code nodes (⚠️ no external libs; stdlib only) |

### Key MCP Tools You’ll Use
- `search_nodes` / `get_node` → Find and inspect nodes
- `n8n_create_workflow` / `n8n_update_partial_workflow` → Build incrementally
- `n8n_validate_workflow` / `n8n_autofix_workflow` → Ensure correctness
- `n8n_deploy_template` → Deploy from templates
- `n8n_executions` → Monitor runs

> 🧠 Skills activate **automatically** when your query matches their domain (e.g., “How to access webhook data in a Code node?” → triggers `n8n-code-javascript` + `n8n-expression-syntax`).

---

## Getting Started

1. Open this folder in your terminal
2. To use **Ollama** with tools that expect the Anthropic API (like Claude Code), set these environment variables:
   ```bash
   export ANTHROPIC_AUTH_TOKEN=ollama  # required but ignored
   export ANTHROPIC_BASE_URL=http://localhost:11434
   export ANTHROPIC_API_KEY=ollama     # required but ignored
   ```
3. Run `claude --model cogito:8b` (ensure the model is already pulled in Ollama)
4. Say:
   - `"create a skill for [something]"` → to build general skills
   - `"build an n8n workflow that..."` → to trigger n8n skills
   - `"deploy a webhook-to-Slack workflow"` → full end-to-end n8n automation

---

## Best Practices

- Always validate workflows before deployment (`n8n_validate_workflow`)
- Use `workflows/n8n/` to store `.json` exports of your workflows
- Prefer JavaScript over Python in Code nodes (better support, more features)
- Remember: **webhook data lives under `$json.body`** — a common gotcha!
- When debugging, ask: “Why is validation failing?” → `n8n-validation-expert` will help

---

**Built for:** Claude Code for Personal Use