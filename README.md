# axls-claude-code

[![Version](https://img.shields.io/badge/version-1.2.1-blue.svg)](https://github.com/Axlfc/axls-claude-code/releases)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-Plugin-purple.svg)](https://claude.ai)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0%2B-blue.svg)](https://www.typescriptlang.org/)

Este repositorio contiene un plugin para Claude Code diseñado para acelerar el desarrollo en un stack tecnológico específico: **Next.js, TypeScript, Fastify, PostgreSQL, Docker y Kubernetes**. Es un sistema de "Skills" y "Agentes" especializados, optimizado para los proyectos `cognito-stack`, `Tarragona Connect (TC)` y `RuneScript`.

## ✨ Features

### 🔧 Commands
10 slash commands for rapid development tasks:
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

### 🤖 2 AI Agents
- `mcp-finder` - MCP server discovery and configuration
- `security-engineer` - Security auditing and hardening

### 🎯 16 Specialized Skills

**Creation Tools:**
- `create-agent` - Build Claude Code agents
- `create-command` - Build slash commands
- `create-hook` - Create automation hooks
- `create-mcp` - Configure MCP servers
- `create-skill` - Create new skills

**DevOps & Infrastructure:**
- `devops-engineer` - Docker, Kubernetes, CI/CD, observability

**Database:**
- `postgres-expert` - Schema design, query optimization, indexing

**State Management:**
- `zustand-expert` - Store patterns, persistence, TC stores

**n8n Workflow Automation:**
- `n8n-code-javascript` - JavaScript in n8n Code nodes
- `n8n-code-python` - Python in n8n Code nodes
- `n8n-expression-syntax` - n8n expression validation
- `n8n-mcp-tools-expert` - n8n MCP tools guide
- `n8n-node-configuration` - Node configuration help
- `n8n-validation-expert` - Validation error interpretation
- `n8n-workflow-patterns` - Workflow architectural patterns
- `n8n-workflow-expert` - Complete workflow design and optimization

---

Este plugin sigue el principio **"Don't Build Agents, Build Skills Instead"**:

-   **Skills (Comandos Slash `/`)**: Son herramientas predecibles y altamente especializadas que generan código o configuración para tareas recurrentes. Son rápidos, eficientes y siguen las mejores prácticas del stack.
-   **Agentes**: Son expertos autónomos que se activan según el contexto de tu trabajo. Proporcionan orientación estratégica, auditan código y aplican las mejores prácticas, pero no escriben grandes volúmenes de código por sí mismos.

---

## Inicio Rápido

### 1. Requisitos Previos
- Editor de código compatible con Claude Code (ej. VS Code con la extensión de Claude).
- Conocimientos básicos de Git y GitHub.

### 2. Instalación
Para instalar el plugin y empezar a usarlo, ejecuta el siguiente comando en el chat de Claude:

```bash
/plugin install Axlfc/axls-claude-code
```

### 3. Uso de Skills
En cualquier archivo o en el chat, escribe `/` para ver la lista de comandos disponibles.

-   **Ejemplo**: Escribe `/api-endpoint` y describe el endpoint que necesitas: `POST /api/users con schema { name: string, email: string } y auth JWT`.

### 4. Activación de Agentes
Los 2 agentes especializados (mcp-finder y security-engineer) se activan automáticamente según el contexto relevante. Para más detalles, consulta [docs/AGENTS_REFERENCE.md](./docs/AGENTS_REFERENCE.md).

---

## Estructura del Repositorio

```
axls-claude-code/
├── README.md
├── .claude/
│   ├── commands/     # -> Implementación de los Skills (Slash Commands)
│   └── agents/       # -> Implementación de los Agentes
├── docs/             # -> Documentación detallada
└── templates/        # -> Plantillas de código reutilizables usadas por los Skills
```

---

## Skills Disponibles

A continuación se muestra una lista de los principales skills. Para una descripción completa y ejemplos de cada uno, consulta la [**Referencia de Skills**](./docs/SKILLS_REFERENCE.md).

<details>
<summary><strong>Ver lista de Skills</strong></summary>

### Desarrollo de Backend y API
- **/api-endpoint**: Genera un endpoint completo de API REST para Fastify.
- **/db-migration**: Crea scripts de migración `up`/`down` para PostgreSQL.
- **/api-test**: Genera un test de integración para un endpoint de Fastify.
- **/api-protect**: Aplica un middleware de autenticación a un endpoint.
- **/edge-function-new**: Crea el scaffolding para una nueva Edge Function de Supabase.

### Desarrollo Frontend (Tarragona Connect)
- **/component-new**: Crea un nuevo componente de React.
- **/page-new**: Crea una nueva página (ruta) en Next.js.
- **/store-new**: Genera un nuevo store de Zustand.

### Infraestructura y DevOps
- **/docker-service**: Añade un nuevo servicio a un `docker-compose.yml`.
- **/k8s-manifest**: Genera manifiestos de Kubernetes (Deployment, Service, etc.).
- **/sentry-integration**: Configura Sentry para monitoreo de errores.

### Calidad y Productividad
- **/test-gen**: Genera tests unitarios o de integración (Jest/Pytest).
- **/lint-fix**: Formatea y corrige errores de linting.
- **/new-workflow**: Crea la estructura base para un workflow de n8n.
- **/types-gen**: Genera tipos de TypeScript desde un esquema de Supabase.
- **/docs-generate**: Genera documentación para una función o clase.
- **/code-explain**: Explica un fragmento de código.
- **/code-optimize**: Sugiere mejoras de rendimiento.
- **/code-cleanup**: Realiza una limpieza general del código.
- **/feature-plan**: Ayuda a diseñar un plan de implementación.
- **/new-task**: Crea una nueva tarea o issue.

</details>

---

## Publicación y Mantenimiento del Plugin

### Actualizar el Plugin
Cuando realices cambios en los skills o agentes:
1.  Asegúrate de que los cambios estén confirmados y subidos a la rama principal.
2.  Si es un cambio significativo, considera actualizar la versión en `.claude-plugin/plugin.json`.
3.  Los usuarios pueden obtener la última versión con el comando:
    ```bash
    /plugin update axls-claude-code
    ```

### Compartir el Plugin
Para compartir el plugin con otros, proporciona el comando de instalación mencionado en la sección de "Inicio Rápido". También puedes contribuir a los repositorios de la comunidad de Claude Code.

Para más detalles sobre la publicación, versionado y solución de problemas, consulta la documentación oficial de Claude Code.
