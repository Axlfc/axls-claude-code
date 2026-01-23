# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2026-01-23

### Added
- **Hooks System:** Skill auto-activation system with 3 hook files
  - `skill-activation-prompt.md` - Intelligent skill routing
  - `post-tool-use-tracker.md` - Usage analytics tracking
  - `skill-rules.json` - Configuration for 6 auto-activated skills
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
