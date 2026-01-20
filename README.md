# axls-claude-code

Este repositorio contiene un plugin para Claude Code diseñado para acelerar el desarrollo en un stack tecnológico específico: Next.js, TypeScript, Fastify, PostgreSQL, Docker y Kubernetes. Es un sistema de "Skills" y "Agentes" especializados, optimizado para los proyectos `cognito-stack`, `Tarragona Connect (TC)` y `RuneScript`.

## Filosofía

Este plugin sigue el principio **"Don't Build Agents, Build Skills Instead"**.

*   **Skills (Comandos Slash `/`)**: Son herramientas altamente especializadas y predecibles que generan código o configuración para tareas recurrentes. Son rápidos, eficientes y siguen las mejores prácticas del stack.
*   **Agentes**: Son expertos autónomos que se activan según el contexto de tu trabajo. Proporcionan orientación estratégica, auditan código y aplican las mejores prácticas, pero no escriben grandes volúmenes de código ellos mismos.

---

## Quick Start

1.  **Instalación**: Clona este repositorio en tu máquina local.
2.  **Claude Code**: Abre el repositorio en un editor compatible con Claude Code (como VS Code con la extensión de Claude).
3.  **Uso de Skills**: En un archivo o en el chat, escribe `/` para ver la lista de comandos disponibles.
    *   **Ejemplo**: Escribe `/api-endpoint` y describe el endpoint que necesitas: `POST /api/users con schema { name: string, email: string } y auth JWT`.
4.  **Activación de Agentes**: Simplemente trabaja como lo harías normalmente. Los agentes se activarán automáticamente cuando detecten un contexto relevante.
    *   **Ejemplo**: Empieza a escribir un `Dockerfile` y el `devops-engineer` se activará para ofrecerte consejos sobre optimización y seguridad.

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

## Agentes Especializados

*   **`devops-engineer`**: Experto en Docker, Kubernetes, CI/CD y observabilidad.
*   **`n8n-workflow-expert`**: Especialista en el diseño de workflows de n8n.
*   **`postgres-expert`**: Experto en diseño de bases de datos, migraciones y optimización.
*   **`security-engineer`**: Especialista en compliance ENS/RGPD y seguridad de contenedores.
*   **`zustand-expert`**: Arquitecto frontend experto en el estado de Tarragona Connect.
