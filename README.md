# axls-claude-code

Este repositorio contiene un plugin para Claude Code diseñado para acelerar el desarrollo en un stack tecnológico específico: **Next.js, TypeScript, Fastify, PostgreSQL, Docker y Kubernetes**. Es un sistema de "Skills" y "Agentes" especializados, optimizado para los proyectos `cognito-stack`, `Tarragona Connect (TC)` y `RuneScript`.

## Filosofía

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
Simplemente trabaja como lo harías normalmente. Los agentes se activarán automáticamente cuando detecten un contexto relevante.

-   **Ejemplo**: Empieza a escribir un `Dockerfile` y el agente `devops-engineer` se activará para ofrecerte consejos sobre optimización y seguridad.

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

## Agentes Especializados

Estos son los agentes que trabajan proactivamente para ayudarte. Para una descripción detallada de sus roles y activadores, consulta la [**Referencia de Agentes**](./docs/AGENTS_REFERENCE.md).

<details>
<summary><strong>Ver lista de Agentes</strong></summary>

### Arquitectura y Diseño
- **`system-architect`**: Ofrece orientación en el diseño de arquitectura de software.
- **`backend-architect`**: Especialista en el diseño de APIs y lógica de negocio.
- **`frontend-architect`**: Experto en arquitectura de aplicaciones frontend.
- **`postgres-expert`**: Asistencia experta en todo lo relacionado con PostgreSQL.
- **`n8n-workflow-expert`**: Especialista en el diseño de workflows de n8n.

### Calidad y Cumplimiento
- **`devops-engineer`**: Experto en Docker, Kubernetes, CI/CD y observabilidad.
- **`security-engineer`**: Especialista en seguridad de aplicaciones y cumplimiento normativo.
- **`performance-engineer`**: Ayuda a identificar y solucionar cuellos de botella de rendimiento.
- **`refactoring-expert`**: Sugiere refactorizaciones para mejorar la calidad del código.

### Investigación y Documentación
- **`tech-stack-researcher`**: Realiza investigaciones sobre nuevas tecnologías.
- **`technical-writer`**: Ayuda a escribir documentación clara y concisa.
- **`learning-guide`**: Proporciona recursos de aprendizaje y tutoriales.
- **`deep-research-agent`**: Realiza investigación profunda sobre un tema específico.
- **`requirements-analyst`**: Ayuda a refinar los requisitos de una nueva funcionalidad.

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
