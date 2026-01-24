# Agents Reference

**Philosophy:** Agents are for **coordination** of external systems and multi-step workflows. Knowledge domains should be **skills**.

**Current Agents:** 2

---

## Active Agents

### mcp-finder
**Purpose:** MCP server discovery and configuration helper

**Type:** Coordinator

**When to Use:**
- Finding appropriate MCP servers for a task
- Configuring `.mcp.json`
- Troubleshooting MCP server issues
- Understanding MCP capabilities

**Why Agent (Not Skill):** Coordinates external MCP registry discovery and helps configure integration files.

---

### cicd-engineer
**Purpose:** CI/CD automation and deployment coordination

**Type:** Coordinator

**When to Use:**
- Checking pipeline status
- Triggering deployments
- Managing releases
- CI/CD troubleshooting

**Why Agent (Not Skill):** Coordinates multiple external APIs (Forgejo, Kubernetes) to automate deployment workflows.

---

## Converted to Skills

The following agents have been converted to skills following Anthropic best practices:

- **security-engineer** → `security-auditing` skill
  - Reason: Security knowledge domain, not coordination
  - Location: `.claude/skills/security-auditing/`

- **observability-engineer** → `observability` skill
  - Reason: Monitoring knowledge domain, not coordination
  - Location: `.claude/skills/observability/`

See [SKILLS_REFERENCE.md](./SKILLS_REFERENCE.md) for complete skill documentation.
