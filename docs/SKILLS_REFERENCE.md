# Skills Reference

Complete reference for all 16 specialized skills in axls-claude-code.

**Quick Stats:**
- **Total Skills:** 16
- **Categories:** 5 (Creation, DevOps, Database, State Management, n8n Automation)
- **Supporting Documentation:** 50+ specialized guides
- **Production Examples:** Included in all skills

---

## Creation Tools (5 Skills)

These skills help you create new agents, commands, hooks, MCP servers, and skills.

### create-agent
**Description:** Build new Claude Code agents for specialized tasks

**Location:** `.claude/skills/create-agent/`

**When to Use:**
- Creating a new specialized AI agent
- Building custom domain expertise
- Automating complex multi-step tasks

**Key Features:**
- Agent scaffolding with best practices
- Trigger keyword configuration
- Response format templates
- Testing guidelines

**Trigger Keywords:** `create agent`, `new agent`, `agent`, `build agent`

---

### create-command
**Description:** Create slash commands for common development tasks

**Location:** `.claude/skills/create-command/`

**When to Use:**
- Creating a new `/command` for your workflow
- Building repetitive task automation
- Quick scaffolding commands

**Key Features:**
- Command scaffolding template
- Parameter configuration
- Help text generation
- Examples and error handling

**Trigger Keywords:** `create command`, `slash command`, `new command`, `/command`

---

### create-hook
**Description:** Build automation hooks for Claude Code workflows

**Location:** `.claude/skills/create-hook/`

**When to Use:**
- Automating skill activation
- Creating custom post-processing
- Building workflow automation

**Key Features:**
- Hook scaffolding with event types
- Event filtering logic
- Response pattern templates

**Trigger Keywords:** `create hook`, `new hook`, `hook`, `automation`

---

### create-mcp
**Description:** Configure and set up MCP (Model Context Protocol) servers

**Location:** `.claude/skills/create-mcp/`

**When to Use:**
- Adding new MCP servers to `.mcp.json`
- Configuring server authentication
- Setting up MCP tool integration

**Key Features:**
- MCP server configuration templates
- Authentication setup guides
- Tool discovery and mapping
- Troubleshooting guides

**Trigger Keywords:** `mcp`, `create mcp`, `configure server`, `mcp server`

---

### create-skill
**Description:** Build new specialized skills for axls-claude-code

**Location:** `.claude/skills/create-skill/`

**When to Use:**
- Creating a new skill with progressive disclosure
- Building domain-specific expertise
- Following Anthropic best practices

**Key Features:**
- SKILL.md scaffolding
- Supporting file templates
- Progressive disclosure patterns
- Examples and testing structure

**Trigger Keywords:** `create skill`, `new skill`, `skill`, `build skill`

---

## DevOps & Infrastructure Skills (1 Skill)

### devops-engineer
**Description:** Senior DevOps engineer expertise for containerization, Kubernetes orchestration, CI/CD, and infrastructure observability

**Location:** `.claude/skills/devops-engineer/`

**Key Features:**
- Docker multi-stage builds with security hardening (non-root users, read-only filesystems)
- Production Kubernetes manifests with health probes, resource limits, network policies
- GitHub Actions CI/CD patterns (rolling, blue-green, canary deployments)
- Prometheus/Grafana/Loki observability stack configuration
- AWS EKS best practices and cost optimization

**Supporting Files:**
- `docker-best-practices.md` (275 lines) - Container optimization, security hardening, vulnerability scanning
- `kubernetes-reference.md` (350 lines) - Production manifests, health checks, policies, pod disruption budgets
- `ci-cd-patterns.md` (400+ lines) - GitHub Actions workflows, deployment strategies, secret management
- `observability-stack.md` (350+ lines) - Prometheus, Grafana dashboards, Loki logging, Alertmanager

**Trigger Keywords:** `docker`, `kubernetes`, `k8s`, `deployment`, `monitoring`, `prometheus`, `grafana`, `ci/cd`, `eks`, `infrastructure`, `devops`

**When to Use:**
- Building production Docker images
- Designing Kubernetes clusters
- Setting up CI/CD pipelines
- Implementing observability stack
- AWS EKS deployment and optimization

---

## Database Skills (1 Skill)

### postgres-expert
**Description:** PostgreSQL DBA expertise for schema design, query optimization, and high-performance database architecture

**Location:** `.claude/skills/postgres-expert/`

**Key Features:**
- Database normalization (1NF through BCNF) with design patterns
- 6 index types with use cases: B-tree, Hash, GiST, GIN, BRIN
- Query optimization with EXPLAIN ANALYZE walkthrough
- Multi-tenant SaaS schema patterns with real examples
- Advanced stored procedures, materialized views, and constraints
- Row-level security (RLS) policies

**Supporting Files:**
- `schema-design-guide.md` (420 lines) - Normalization, ER modeling, temporal patterns, event sourcing
- `indexing-strategies.md` (450 lines) - Index types, EXPLAIN ANALYZE, maintenance, performance monitoring
- `query-optimization.md` (420 lines) - Join optimization, CTEs, window functions, N+1 solutions
- `postgresql-examples.sql` (750+ lines) - Multi-tenant SaaS schema, migrations, stored procedures

**Trigger Keywords:** `postgresql`, `postgres`, `database`, `schema`, `migration`, `query`, `index`, `sql`, `performance`, `dba`

**When to Use:**
- Designing database schemas
- Optimizing slow queries
- Implementing indexing strategies
- Planning database migrations
- Setting up multi-tenant databases

---

## State Management Skills (1 Skill)

### zustand-expert
**Description:** Zustand state management expertise for Tarragona Connect with store patterns, persistence strategies, and performance optimization

**Location:** `.claude/skills/zustand-expert/`

**Key Features:**
- 7 design patterns: normalized data, async actions, undo/redo, middleware, devtools
- 4-phase migration strategy: localStorage → PostgreSQL hybrid → full PostgreSQL
- Complete inventory of 22 TC stores with dependencies and architecture diagram
- Full TypeScript examples with Jest unit tests and coverage
- React component integration patterns and performance optimization

**Supporting Files:**
- `store-patterns.md` (420 lines) - Design patterns, async handling, middleware, optimizations
- `persistence-migration.md` (500+ lines) - Migration strategies, PostgreSQL schema, hybrid pattern, conflict resolution
- `tc-stores-reference.md` (450 lines) - All 22 TC stores, dependencies, data flow visualization
- `zustand-examples.ts` (450+ lines) - TypeScript examples with Jest tests, React integration

**Trigger Keywords:** `zustand`, `store`, `state management`, `persistence`, `localStorage`, `redux`, `tc`, `tarragona`, `state`

**When to Use:**
- Building global state with Zustand
- Migrating from localStorage to PostgreSQL
- Optimizing store performance
- Adding persistence to stores
- Implementing complex state patterns

---

## n8n Workflow Automation Skills (8 Skills)

### n8n-workflow-expert
**Description:** Expert in designing complex n8n workflows with cognito-stack integration, error handling, and optimization

**Location:** `.claude/skills/n8n-workflow-expert/`

**Key Features:**
- 8 core workflow patterns: retry/backoff, fan-out/fan-in, deduplication, throttling
- cognito-stack integration with explicit service URLs (Ollama:11434, Qdrant:6333)
- Complete testing strategies: unit, integration, load testing with Apache Bench/Artillery
- 4 executable workflow JSON examples with error handling
- RAG (Retrieval-Augmented Generation) patterns

**Supporting Files:**
- `workflow-patterns.md` (320 lines) - Core patterns with implementations
- `cognito-stack-integration.md` (380 lines) - Service URLs, RAG patterns, embedding strategies
- `testing-strategies.md` (350 lines) - Unit, integration, load testing approaches
- `n8n-examples.json` (230 lines) - Complete executable workflow examples

**Trigger Keywords:** `n8n`, `workflow`, `automation`, `integration`, `webhook`, `trigger`, `ai`, `orchestration`

**When to Use:**
- Designing complex workflows
- Integrating with cognito-stack services
- Setting up workflow error handling
- Testing and load testing workflows
- Building RAG pipelines

---

### n8n-code-javascript
**Description:** JavaScript execution in n8n Code nodes with best practices

**Location:** `.claude/skills/n8n-code-javascript/`

**When to Use:**
- Writing JavaScript code in n8n Code nodes
- Transforming data with JavaScript
- Implementing custom logic in workflows

**Trigger Keywords:** `n8n javascript`, `n8n code`, `javascript code node`

---

### n8n-code-python
**Description:** Python execution in n8n Code nodes with best practices

**Location:** `.claude/skills/n8n-code-python/`

**When to Use:**
- Writing Python code in n8n Code nodes
- Using Python libraries in workflows
- Implementing machine learning in workflows

**Trigger Keywords:** `n8n python`, `python code node`, `n8n code python`

---

### n8n-expression-syntax
**Description:** Complete guide to n8n expression language syntax and functions

**Location:** `.claude/skills/n8n-expression-syntax/`

**When to Use:**
- Using n8n's native expression language
- Data transformation with expressions
- Debugging expression errors

**Trigger Keywords:** `n8n expression`, `expression syntax`, `n8n language`

---

### n8n-mcp-tools-expert
**Description:** Guide to using MCP tools in n8n workflows

**Location:** `.claude/skills/n8n-mcp-tools-expert/`

**When to Use:**
- Integrating MCP tools in workflows
- Configuring MCP tool nodes
- Discovering available MCP tools

**Trigger Keywords:** `mcp tools`, `n8n mcp`, `mcp integration`

---

### n8n-node-configuration
**Description:** Help configuring n8n nodes with best practices

**Location:** `.claude/skills/n8n-node-configuration/`

**When to Use:**
- Configuring specific n8n nodes
- Understanding node parameters
- Setting up node credentials

**Trigger Keywords:** `n8n node`, `node configuration`, `node setup`

---

### n8n-validation-expert
**Description:** Understanding and resolving n8n validation errors

**Location:** `.claude/skills/n8n-validation-expert/`

**When to Use:**
- Debugging n8n validation errors
- Understanding error messages
- Fixing workflow validation issues

**Trigger Keywords:** `n8n error`, `validation error`, `n8n validation`

---

### n8n-workflow-patterns
**Description:** Architectural patterns for complex n8n workflows

**Location:** `.claude/skills/n8n-workflow-patterns/`

**When to Use:**
- Designing workflow architecture
- Implementing best practice patterns
- Scaling workflows

**Trigger Keywords:** `workflow pattern`, `architecture pattern`, `n8n pattern`

---

## Quick Access

### By Category
- **Creation:** create-agent, create-command, create-hook, create-mcp, create-skill
- **Infrastructure:** devops-engineer
- **Database:** postgres-expert
- **State Management:** zustand-expert
- **Automation:** n8n-workflow-expert, n8n-code-javascript, n8n-code-python, n8n-expression-syntax, n8n-mcp-tools-expert, n8n-node-configuration, n8n-validation-expert, n8n-workflow-patterns

### By Technology
- **Docker/Kubernetes:** devops-engineer
- **PostgreSQL:** postgres-expert
- **Zustand:** zustand-expert
- **n8n:** All 8 n8n skills
- **General:** create-agent, create-command, create-hook, create-mcp, create-skill

---

## Skill Activation

Skills are automatically activated based on context keywords. Configuration is in `.claude/hooks/skill-rules.json`:

```json
{
  "skills": [
    {
      "name": "devops-engineer",
      "triggers": ["docker", "kubernetes", "k8s", "deployment"],
      "confidence_threshold": 0.8
    },
    {
      "name": "postgres-expert",
      "triggers": ["postgresql", "postgres", "database", "schema"],
      "confidence_threshold": 0.8
    },
    // ... etc
  ]
}
```

---

## References

- [AGENTS_REFERENCE.md](./AGENTS_REFERENCE.md) - 2 remaining AI agents
- [COMMANDS_REFERENCE.md](./COMMANDS_REFERENCE.md) - All slash commands
- [AGENT_TO_SKILL_CONVERSION_REPORT.md](../AGENT_TO_SKILL_CONVERSION_REPORT.md) - Detailed conversion report
