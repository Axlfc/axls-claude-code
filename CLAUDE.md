# Project: axls-claude-code

Este repositorio es un plugin de Claude Code para el desarrollo moderno, enfocado en Next.js, TypeScript, PostgreSQL, y n8n. Contiene un conjunto de herramientas de IA para acelerar el desarrollo de software de alta calidad.

## Stack & Technologies
- **Frontend:** Next.js, React, Zustand, shadcn/ui, Tailwind CSS
- **Backend:** Fastify, Node.js
- **Lenguajes:** TypeScript, Python
- **Base de Datos:** PostgreSQL
- **Infraestructura:** Docker, Kubernetes (EKS)
- **Automatización:** n8n

## Structure
- **`.claude/`**: El núcleo del plugin (skills, commands, agents).
- **`.claude-plugin/`**: Manifiesto y metadatos del plugin.
- **`docs/`**: Documentación técnica detallada.
- **`templates/`**: Plantillas de código "production-ready".
- **`CLAUDE.md`**: Este archivo, el punto de entrada de contexto principal.

## Code Conventions
- **TypeScript/JS:** Airbnb style, formateado con Prettier.
- **Python:** PEP 8, formateado con Ruff.
- **Commits:** Conventional Commits standard.

## Available Tools
- **Commands:** 10 slash commands para acciones rápidas (ver @docs/COMMANDS_REFERENCE.md)
- **Agents:** 4 specialized AI agents (ver @docs/AGENTS_REFERENCE.md)
- **Skills:** 16 skills para flujos de trabajo complejos (ver @docs/SKILLS_REFERENCE.md)

## Important Context
- **Production-Ready:** Todo el código generado debe ser TypeScript `strict`, incluir manejo de errores robusto, validación de inputs (con Zod), y logging estructurado.
- **Seguridad:** Priorizar la seguridad en todo, especialmente en la configuración de infraestructura y en el código de API.

## References
- @docs/STACK_INTEGRATION.md
- @docs/n8n-guidelines.md
- @.claude-plugin/MCP-SERVERS.md
