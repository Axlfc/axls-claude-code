# Agents Reference

This document lists all AI agents in axls-claude-code.

**Note:** Most specialized functionality has been converted to skills for better modularity and progressive disclosure. See [SKILLS_REFERENCE.md](./SKILLS_REFERENCE.md) for the complete list of 16 available skills.

---

## Active Agents (2)

### mcp-finder
**Purpose:** MCP server discovery and configuration helper

**When to Use:**
- Finding appropriate MCP servers for a task
- Configuring `.mcp.json`
- Troubleshooting MCP server issues
- Understanding MCP capabilities and available tools

**Activation:** Automatically activates when discussing MCP servers or configuration.

**Key Capabilities:**
- Discover available MCP servers
- Suggest optimal server combinations for workflows
- Generate MCP configuration files
- Troubleshoot connection issues
- Document MCP tool capabilities

---

### security-engineer
**Purpose:** Security auditing and infrastructure hardening

**When to Use:**
- Security audits of code or infrastructure
- Identifying vulnerabilities and security risks
- Implementing security best practices
- Compliance and standards guidance (OWASP, CIS)
- Secure configuration reviews

**Activation:** Automatically activates when discussing security topics, penetration testing, or hardening.

**Key Capabilities:**
- Code security analysis
- Infrastructure security assessment
- Vulnerability identification
- Security best practices implementation
- Compliance framework guidance
- Threat modeling assistance

---

## Converted to Skills

The following agents have been converted to skills with progressive disclosure patterns (Phase 2 of v1.2.0 optimization). Each skill is modular, maintainable, and includes production-ready examples:

### devops-engineer → DevOps Engineer Skill
**Location:** `.claude/skills/devops-engineer/`
**Scope:** Docker, Kubernetes, CI/CD, infrastructure observability

Features:
- Multi-stage Docker builds with security hardening
- Production Kubernetes manifests with health probes and policies
- GitHub Actions CI/CD patterns (rolling, blue-green, canary)
- Prometheus/Grafana/Loki observability stack
- AWS EKS best practices and cost optimization

See [SKILLS_REFERENCE.md#devops-engineer](./SKILLS_REFERENCE.md#devops-engineer) for full documentation.

---

### n8n-workflow-expert → n8n Workflow Expert Skill
**Location:** `.claude/skills/n8n-workflow-expert/`
**Scope:** Workflow design, cognito-stack integration, workflow testing

Features:
- 8 core workflow patterns (retry, fan-out/fan-in, deduplication)
- cognito-stack integration with service URLs
- Complete testing strategies (unit, integration, load)
- 4 executable workflow JSON examples
- RAG (Retrieval-Augmented Generation) patterns

See [SKILLS_REFERENCE.md#n8n-workflow-expert](./SKILLS_REFERENCE.md#n8n-workflow-expert) for full documentation.

---

### postgres-expert → PostgreSQL Expert Skill
**Location:** `.claude/skills/postgres-expert/`
**Scope:** Schema design, query optimization, indexing strategies

Features:
- Database normalization (1NF through BCNF)
- 6 index types with use cases
- Query optimization with EXPLAIN ANALYZE
- Multi-tenant SaaS schema patterns
- Advanced stored procedures and views
- Complete PostgreSQL examples (750+ lines)

See [SKILLS_REFERENCE.md#postgres-expert](./SKILLS_REFERENCE.md#postgres-expert) for full documentation.

---

### zustand-expert → Zustand Expert Skill
**Location:** `.claude/skills/zustand-expert/`
**Scope:** State management, store patterns, persistence strategies

Features:
- 7 design patterns (normalized data, async actions, undo/redo)
- 4-phase migration strategy (localStorage → PostgreSQL)
- Complete inventory of 22 TC stores with dependencies
- Full TypeScript examples with Jest tests
- React integration and performance optimization

See [SKILLS_REFERENCE.md#zustand-expert](./SKILLS_REFERENCE.md#zustand-expert) for full documentation.

---

## Rationale for Conversion

The conversion from agents to skills was driven by:

1. **Modularity:** Skills are modular, single-concern components
2. **Maintainability:** Easier to update and extend individual skills
3. **Discoverability:** Progressive disclosure reduces cognitive load
4. **Production-Ready:** All skills include executable examples
5. **Best Practices:** Follows Anthropic guidelines for skill design

---

## Usage Guidelines

### When to Use Agents (2 remaining)
- **mcp-finder:** When you need to discover or configure MCP servers
- **security-engineer:** When you need security audits or hardening guidance

### When to Use Skills (16 available)
- When you need specialized guidance in a specific domain
- When you need production-ready code examples
- When you want progressive disclosure (basic → advanced)
- When implementing best practices in your stack

Skills are automatically activated based on context keywords. See `.claude/hooks/skill-rules.json` for activation configuration.

---

## Migration from Agents to Skills

If you were using the converted agents, you can find their functionality in the corresponding skills:

| Old Agent | New Skill | Location |
|-----------|-----------|----------|
| devops-engineer | DevOps Engineer | `.claude/skills/devops-engineer/` |
| n8n-workflow-expert | n8n Workflow Expert | `.claude/skills/n8n-workflow-expert/` |
| postgres-expert | PostgreSQL Expert | `.claude/skills/postgres-expert/` |
| zustand-expert | Zustand Expert | `.claude/skills/zustand-expert/` |

All functionality is preserved, with added progressive disclosure and production examples.

---

## References

- [SKILLS_REFERENCE.md](./SKILLS_REFERENCE.md) - Complete skills documentation
- [COMMANDS_REFERENCE.md](./COMMANDS_REFERENCE.md) - All slash commands
- [.claude/hooks/skill-rules.json](../.claude/hooks/skill-rules.json) - Skill activation configuration
- [AGENT_TO_SKILL_CONVERSION_REPORT.md](../AGENT_TO_SKILL_CONVERSION_REPORT.md) - Detailed conversion report
