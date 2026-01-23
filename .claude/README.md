# Claude Code Plugin Configuration

This directory contains the core configuration for the axls-claude-code plugin.

## Structure

```
.claude/
├── commands/          # 10 slash commands
├── agents/            # 2 AI agents
├── skills/            # 16 reusable skills
└── settings.json      # Plugin settings
```

## Quick Reference

### Commands (10)
Run `/` in Claude Code to see all available commands.

Key commands:
- `/api-endpoint` - Generate Fastify REST endpoints
- `/component-new` - Create React components
- `/db-migration` - PostgreSQL migrations
- `/k8s-manifest` - Kubernetes manifests

### Skills (16)
Skills auto-activate based on context.

Key skills:
- `devops-engineer` - Docker, K8s, CI/CD
- `postgres-expert` - Database optimization
- `n8n-workflow-expert` - Workflow automation
- `zustand-expert` - State management

### Agents (2)
- `mcp-finder` - MCP server discovery
- `security-engineer` - Security auditing

## Customization

Edit files in this directory to customize behavior.

**Tip:** Keep `SKILL.md` files under 500 lines. Use progressive disclosure for complex skills.

## Documentation

See [docs/](../docs/) for detailed reference guides.
