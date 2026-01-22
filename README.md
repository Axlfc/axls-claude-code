# axls-claude-code

Este repositorio contiene un plugin para Claude Code diseñado para acelerar el desarrollo en un stack tecnológico específico: Next.js, TypeScript, Fastify, PostgreSQL, Docker y Kubernetes. Es un sistema de "Skills" y "Agentes" especializados, optimizado para los proyectos `cognito-stack`, `Tarragona Connect (TC)` y `RuneScript`.

## Filosofía

Este plugin sigue el principio **"Don't Build Agents, Build Skills Instead"**.

*   **Comandos (Slash Commands `/`)**: Son herramientas altamente especializadas y predecibles que generan código o configuración para tareas recurrentes. Son rápidos, eficientes y siguen las mejores prácticas del stack. Se definen en `.claude/commands/`.
*   **Skills**: Son conocimientos que el asistente de IA carga para poder realizar tareas complejas, como crear nuevos agentes o entender cómo construir workflows de n8n. Se definen en `.claude/skills/`.
*   **Agentes**: Son expertos autónomos que se activan según el contexto de tu trabajo. Proporcionan orientación estratégica, auditan código y aplican las mejores prácticas, pero no escriben grandes volúmenes de código ellos mismos. Se definen en `.claude/agents/`.

---

## Quick Start

1.  **Instalación**: Clona este repositorio en tu máquina local.
2.  **Claude Code**: Abre el repositorio en un editor compatible con Claude Code (como VS Code con la extensión de Claude).
3.  **Uso de Comandos**: En un archivo o en el chat, escribe `/` para ver la lista de comandos disponibles.
    *   **Ejemplo**: Escribe `/api-endpoint` y describe el endpoint que necesitas: `POST /api/users con schema { name: string, email: string } y auth JWT`.
4.  **Activación de Agentes**: Simplemente trabaja como lo harías normalmente. Los agentes se activarán automáticamente cuando detecten un contexto relevante.
    *   **Ejemplo**: Empieza a escribir un `Dockerfile` y el `devops-engineer` se activará para ofrecerte consejos sobre optimización y seguridad.

---

## Estructura del Repositorio

```
axls-claude-code/
├── README.md
├── CLAUDE.md         # -> Memoria principal y reglas para el asistente de IA
├── .claude/
│   ├── commands/     # -> Implementación de los Comandos (Slash Commands)
│   ├── skills/       # -> Implementación de los Skills
│   └── agents/       # -> Implementación de los Agentes
├── .claude-plugin/
│   └── plugin.json   # -> Manifiesto del plugin con todos los componentes
├── docs/             # -> Documentación detallada y guías
└── templates/        # -> Plantillas de código reutilizables
```

---

## Comandos Disponibles

### Desarrollo
*   `/api-endpoint`: Genera un endpoint completo de API REST para Fastify.
*   `/component-new`: Crea un nuevo componente de React para Tarragona Connect.
*   `/store-new`: Genera un nuevo store de Zustand para Tarragona Connect.
*   `/db-migration`: Crea scripts de migración `up`/`down` para PostgreSQL.
*   `/new-workflow`: Scaffolding para un workflow de n8n.

### Infraestructura & DevOps
*   `/docker-service`: Añade un nuevo servicio a un `docker-compose.yml`.
*   `/k8s-manifest`: Genera manifiestos de Kubernetes (Deployment, Service, etc.).
*   `/sentry-integration`: Configura Sentry para monitoreo de errores.

### Calidad
*   `/test-gen`: Genera tests unitarios o de integración (Jest/Pytest).
*   `/lint-fix`: Formatea y corrige errores de linting en un fragmento de código.

---

## Skills Principales

*   **`create-*`**: Una familia de skills (`create-agent`, `create-command`, `create-skill`, etc.) para extender las capacidades de este plugin.
*   **`n8n-*`**: Un conjunto de skills expertos para construir, validar y depurar workflows de n8n de manera eficiente.

---

## Agentes Especializados

*   **`devops-engineer`**: Experto en Docker, Kubernetes, CI/CD y observabilidad.
*   **`mcp-finder`**: Busca en línea para encontrar nuevos servidores MCP.
*   **`n8n-workflow-expert`**: Especialista en el diseño de workflows de n8n.
*   **`postgres-expert`**: Experto en diseño de bases de datos, migraciones y optimización.
*   **`security-engineer`**: Especialista en compliance ENS/RGPD y seguridad de contenedores.
*   **`zustand-expert`**: Arquitecto frontend experto en el estado de Tarragona Connect.
