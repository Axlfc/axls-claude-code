# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.3.0] - 2026-01-24

### Added
- New agent: `observability-engineer` for logs and metrics monitoring
  - Loki/LogQL integration for log querying
  - Prometheus/PromQL integration for metrics
  - Service health checks for cognito-stack
- New agent: `cicd-engineer` for CI/CD automation
  - Forgejo API integration for pipeline management
  - Kubernetes deployment verification
  - Automated deployment triggers

### Changed
- Agent count increased from 2 to 4
- Enhanced monitoring capabilities with observability-engineer
- Improved CI/CD workflow automation with cicd-engineer

[1.3.0]: https://github.com/Axlfc/axls-claude-code/compare/v1.2.1...v1.3.0

## [1.2.1] - 2026-01-23

### Fixed
- **Compliance:** Removed non-standard hook system to align with official Claude Code standards
- **Compliance:** Corrected frontmatter for 4 skills (devops-engineer, n8n-workflow-expert, postgres-expert, zustand-expert) to use only official `name` and `description` fields
- **Docs:** Updated critical documentation (README.md, CLAUDE.md) to reflect correct agent and skill counts after remediation

## [1.2.0] - 2026-01-23

### Added
- 4 new skills converted from agents with progressive disclosure:
  - `devops-engineer` skill (Docker, Kubernetes, CI/CD, observability)
  - `n8n-workflow-expert` skill (workflow patterns, integration, testing)
  - `postgres-expert` skill (schema design, indexing, optimization)
  - `zustand-expert` skill (store patterns, persistence, TC stores)
- 16 supporting files across 4 new skills (7,310+ lines of documentation)
- Production-ready examples for all new skills

### Changed
- Converted 4 agents to skills following Anthropic best practices
- Applied progressive disclosure pattern to new skills
- Updated all documentation to reflect agent/skill inventory changes

### Removed
- 4 agent files (converted to skills):
  - `devops-engineer` agent
  - `n8n-workflow-expert` agent
  - `postgres-expert` agent
  - `zustand-expert` agent
- Non-standard hooks system

### Fixed
- Fixed agent/skill counts in CLAUDE.md and README.md (agents: 6→2, skills: 12→16)
- Fixed skill frontmatters to include required `name` field per Anthropic standards
- Removed non-standard `triggers` field from skill frontmatters
- Updated documentation to remove references to non-standard hook system
- Fixed README.md example referencing removed `devops-engineer` agent

## [1.1.0] - 2026-01-23

### Added
- **Hooks System:** Skill auto-activation system (deprecated in v1.2.1)
- **Templates:** Critical development templates
  - `eslint.config.js` - Strict TypeScript ESLint configuration
  - `jest.config.ts` - TypeScript Jest configuration
  - `github-action.yml` - Complete CI/CD pipeline workflow
- **Documentation:**
  - `CONTRIBUTING.md` - Comprehensive contribution guide
  - `TROUBLESHOOTING.md` - Common issues and solutions
  - `docs/COMMANDS_REFERENCE.md` - Complete commands reference
  - Expanded `MCP-SERVERS.md` with GitHub, PostgreSQL, Docker MCP servers
- **Enhanced MCP Support:**
  - Expanded `.mcp.json.example` with 6 MCP server configurations
  - Security best practices documentation for MCP servers

### Changed
- **CLAUDE.md:** Optimized from 44 to 75 lines with modular structure
  - New Stack & Technologies section
  - Modular Available Tools references
  - Improved Important Context section
- **README.md:** Enhanced with badges and detailed features list
  - Version, License, Claude Code, TypeScript badges
  - 🔧 Detailed 10 Commands breakdown
  - 🤖 Detailed 6 Agents breakdown
  - 💡 Detailed 12 Skills breakdown
- **Plugin.json:** Version bumped to 1.1.0
- **`/store-new` Command:** Completely refactored for production-ready output
  - TypeScript strict mode requirement
  - Comprehensive error handling patterns
  - DevTools integration instructions
  - Test stub generation guidance
  - Logging and validation best practices

### Fixed
- All commands now generate truly production-ready code
- Improved skill organization with planned progressive disclosure pattern
- Enhanced security configurations for infrastructure commands

### Improved
- Code quality standards across all commands
- Documentation organization and completeness
- Developer experience with new troubleshooting guide

## [1.0.0] - 2025-01-23

### Added
- **Commands:** 10 slash commands for rapid development tasks
  - `/api-endpoint` - Generate API endpoint scaffolding
  - `/db-migration` - Create database migrations
  - `/component` - Generate React components
  - `/store-new` - Create Zustand stores
  - `/hook` - Generate custom React hooks
  - `/middleware` - Create Fastify middleware
  - `/workflow` - Generate n8n workflows
  - `/docker` - Generate Docker configurations
  - `/k8s` - Generate Kubernetes manifests
  - `/validate` - Create Zod validation schemas

- **Agents:** 6 specialized AI agents
  - `frontend-architect` - Frontend design and architecture
  - `backend-engineer` - Backend infrastructure and optimization
  - `devops-engineer` - Infrastructure and deployment expertise
  - `db-architect` - Database design and optimization
  - `security-engineer` - Security audits and best practices
  - `code-reviewer` - Code quality and standards enforcement

- **Skills:** 12 specialized workflow skills
  - State management optimization
  - Database schema design
  - API endpoint generation
  - Component architecture
  - Performance optimization
  - Security hardening
  - Testing strategy
  - Documentation generation
  - Docker optimization
  - Kubernetes deployment
  - n8n workflow orchestration
  - Error handling patterns

- **Stack Support:**
  - Next.js (v14+) with React 18+
  - TypeScript (strict mode)
  - Fastify backend framework
  - PostgreSQL database
  - Docker containerization
  - Kubernetes orchestration (EKS)
  - n8n workflow automation
  - Zustand state management
  - shadcn/ui component library
  - Tailwind CSS styling

- **Templates:**
  - Production-ready component templates
  - API route patterns
  - Zustand store templates
  - Docker Compose service templates
  - Kubernetes deployment manifests
  - n8n workflow templates

- **Documentation:**
  - Agent reference guide
  - Commands reference guide
  - Skills reference guide
  - Stack integration guide
  - n8n development guidelines
  - Architecture documentation

### Features
- Automatic context-aware agent activation
- Slash command interface for quick scaffolding
- Production-ready code generation
- TypeScript strict mode compliance
- Error handling with structured logging
- Input validation with Zod
- DevTools integration for state management
- Local storage persistence with PostgreSQL migration path
- MCP server integration (YouTube, Notion, n8n)
- Conventional Commits support

### Architecture
- Modular plugin structure
- Separation of concerns (Commands, Agents, Skills)
- Template-based code generation
- Context-aware routing
- Production-focused best practices
