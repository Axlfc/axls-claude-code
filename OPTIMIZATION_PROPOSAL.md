# Propuesta de Optimización: axls-claude-code
**Fecha:** 23 de Enero, 2026
**Versión Actual:** 1.0.0
**Versión Propuesta:** 1.1.0 (para Fases 1-2)

## 📊 Resumen Ejecutivo

### Estado Actual
El plugin `axls-claude-code` posee una base sólida con 10 comandos, 6 agentes y 12 skills bien definidos. Sus fortalezas radican en la calidad de sus plantillas de código y la claridad de su manifiesto `plugin.json`. Sin embargo, el análisis revela brechas críticas: la mayoría de los skills son monolíticos y exceden las 500 líneas, faltando un sistema de auto-activación de hooks, y una inconsistencia en la calidad "production-ready" de los slash commands. El `CLAUDE.md` actual, aunque conciso, carece de secciones clave.

### Propuesta de Valor
Esta propuesta detalla un plan de 6 fases para transformar el plugin en una referencia de la comunidad. Las mejoras clave incluyen:
1.  **Refactorizar Skills a un patrón de "Progressive Disclosure"** para mejorar la mantenibilidad y eficiencia.
2.  **Implementar un sistema de auto-activación de skills** para una experiencia de usuario más inteligente y proactiva.
3.  **Optimizar `CLAUDE.md`** para un contexto más rico y modular, manteniéndose por debajo de las 100 líneas.
4.  **Estandarizar la calidad de todos los Slash Commands** para asegurar que generen código verdaderamente "production-ready".

El beneficio esperado es un plugin más profesional, eficiente, fácil de mantener y perfectamente alineado con las mejores prácticas oficiales de Anthropic. El esfuerzo estimado para las fases de mayor impacto (1-4) es de 46-70 horas.

---

## 🔍 Hallazgos Detallados

### 1. Comandos Slash (10 comandos auditados)

| Comando | Score | Gaps Identificados | Prioridad | Acción Recomendada |
|---|---|---|---|---|
| `/api-endpoint` | 4.5/5 | Falta ejemplo de uso en la definición. | LOW | Añadir un bloque de ejemplo de uso. |
| `/component-new`| 3/5 | No menciona explícitamente testing, accesibilidad o manejo de estado. | MEDIUM | Añadir instrucciones para generar stubs de tests y considerar accesibilidad (ARIA). |
| `/db-migration` | 3/5 | No especifica manejo de errores (transacciones) ni la necesidad de tests. | MEDIUM | Añadir instrucción para envolver la migración en una transacción (`BEGIN`/`COMMIT`). |
| `/docker-service`| 4/5 | Falta instrucción para añadir health checks. | LOW | Añadir recomendación explícita para `healthcheck`. |
| `/k8s-manifest` | 3.5/5 | No especifica `livenessProbe`/`readinessProbe` ni `securityContext`. | MEDIUM | Añadir instrucciones para incluir health checks y un `securityContext` básico. |
| `/lint-fix` | 5/5 | Sigue las mejores prácticas. | N/A | Ninguna. |
| `/new-workflow` | 3.5/5 | El manejo de errores es básico. | LOW | Mejorar la instrucción de manejo de errores para ser más específica. |
| `/sentry-integration`| 4/5 | Excelente para el manejo de errores, pero podría sugerir tests. | LOW | Añadir sugerencia para testear la integración de Sentry. |
| `/store-new` | 2.5/5 | No menciona tests, manejo de errores en acciones asíncronas, o logging. | HIGH | Refactorizar para incluir instrucciones explícitas de testing y manejo de errores. |
| `/test-gen` | 5/5 | Sigue las mejores prácticas. | N/A | Ninguna. |

**Resumen:**
- Comandos con score >= 4/5: 5
- Comandos con gaps menores: 2
- Comandos que requieren refactor: 3

**Recomendaciones Prioritarias:**
1.  **Refactorizar `/store-new`:** Es el comando más débil. Debe ser actualizado para instruir la generación de tests y el manejo de errores en acciones asíncronas, cumpliendo con la definición de "production-ready".
2.  **Mejorar Comandos de Infraestructura (`/k8s-manifest`, `/db-migration`):** Estos comandos deben incluir por defecto las mejores prácticas de producción como health checks, transacciones y contextos de seguridad.

---

### 2. Agentes AI (6 agentes auditados)

| Agente | Recomendación | Justificación |
|---|---|---|
| `devops-engineer` | Convertir a Skill | Sus activadores son predecibles y se beneficiaría enormemente del progressive disclosure para incluir plantillas de K8s, Dockerfiles, etc. |
| `mcp-finder` | Mantener como Agent | Es un agente de propósito específico, invocado por otro skill, lo cual es un patrón de uso perfecto para un agente. |
| `n8n-workflow-expert` | Convertir a Skill | El dominio es complejo y se beneficiaría de una estructura de progressive disclosure con guías detalladas y patrones de workflows. |
| `postgres-expert` | Convertir a Skill | Ideal para progressive disclosure, con secciones para optimización de queries, diseño de esquemas, y funciones avanzadas. |
| `security-engineer`| Mantener como Agent | El rol de auditoría se adapta bien a un agente autónomo que puede ser invocado en diferentes contextos para revisar código o configuraciones. |
| `zustand-expert` | Convertir a Skill | Perfecto para progressive disclosure, detallando patrones como middleware, persistencia y tests. |

**Agentes a Convertir en Skills:**
- `devops-engineer`, `n8n-workflow-expert`, `postgres-expert`, `zustand-expert`. La conversión permitirá la creación de guías de referencia mucho más ricas y estructuradas usando progressive disclosure, mejorando su utilidad y mantenibilidad.

---

### 3. Skills (12 skills auditados)

**Skills que Exceden el Límite de 500 Líneas (Requieren Refactor Urgente):**
- `n8n-node-configuration` (785 líneas)
- `n8n-code-python` (748 líneas)
- `n8n-code-javascript` (699 líneas)
- `n8n-validation-expert` (689 líneas)
- `create-mcp` (660 líneas)
- `n8n-mcp-tools-expert` (642 líneas)
- `n8n-expression-syntax` (516 líneas)

**Skills Largos (< 500 líneas pero > 200) que se Beneficiarían de Refactor:**
- `create-skill` (417 líneas)
- `n8n-workflow-patterns` (411 líneas)
- `create-agent` (385 líneas)
- `create-command` (298 líneas)
- `create-hook` (237 líneas)

**Progressive Disclosure Opportunities:**
Todos los skills listados arriba son candidatos ideales. El patrón a seguir es:
1.  **`SKILL.md` principal:** Reducirlo a la lógica central (ej. el proceso de entrevista para los skills `create-*`).
2.  **Archivos de Referencia:** Extraer ejemplos largos, plantillas de código, y guías detalladas a archivos separados en el directorio del skill (ej. `examples.md`, `template.md`).
3.  **Usar `@imports`:** Referenciar estos archivos desde el `SKILL.md` principal.

---

### 4. CLAUDE.md Optimization

**Análisis Actual:**
- Líneas actuales: 44
- Contenido principal: Estilo de código, comandos clave, arquitectura y notas.
- Modularidad: Buena, ya usa `@docs/n8n-guidelines.md`.

**Propuesta de Estructura Optimizada:**
```markdown
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
- **Commands:** 10 slash commands para acciones rápidas (ver `@docs/COMMANDS_REFERENCE.md`).
- **Agents:** 6 agentes de IA especializados (ver `@docs/AGENTS_REFERENCE.md`).
- **Skills:** 12 skills para flujos de trabajo complejos (ver `@docs/SKILLS_REFERENCE.md`).

## Important Context
- **Production-Ready:** Todo el código generado debe ser TypeScript `strict`, incluir manejo de errores robusto, validación de inputs (con Zod), y logging estructurado.
- **Seguridad:** Priorizar la seguridad en todo, especialmente en la configuración de infraestructura y en el código de API.

## References
- @docs/STACK_INTEGRATION.md
- @docs/n8n-guidelines.md
- @.claude-plugin/MCP-SERVERS.md
```

**Total Lines: ~75**

---

### 5. Hooks & Auto-Activation System

**Status Actual:** No implementado. El directorio `.claude/hooks/` no existe.

**Propuesta: Implementar Skill Auto-Activation System (diet103 Pattern)**
Se crearán tres nuevos archivos para habilitar la auto-activación inteligente de skills.

**Hook 1: `.claude/hooks/skill-activation-prompt.md`**
```markdown
---
description: Auto-activates skills based on user prompt context.
trigger: UserPromptSubmit
---
You are a routing expert. Your job is to analyze the user's prompt and determine if a specialized skill should be activated to handle it.

1.  **Analyze Prompt:** Read the user's latest prompt.
2.  **Consult Rules:** Load the activation rules from `.claude/hooks/skill-rules.json`.
3.  **Find Match:** Iterate through the skills in the rules file. If the user's prompt contains a high concentration of trigger keywords for a specific skill (above `confidence_threshold`), activate that skill.
4.  **Activate Skill:** If a match is found, use the `Skill` tool to invoke it. Pass the original user prompt to the skill.
5.  **Do Nothing:** If no specific skill matches, do not do anything. Let Claude handle the prompt with its general knowledge.
```

**Hook 2: `.claude/hooks/post-tool-use-tracker.md`**
```markdown
---
description: Tracks tool usage for continuous improvement.
trigger: PostToolUse
---
You are an analytics agent. Your goal is to silently log tool usage to help improve the plugin.

1. **Get Tool Info:** Capture the name of the tool that was just used and its arguments.
2. **Log Data:** Append a new entry to a log file (e.g., `~/.claude-usage-log.json`) with the tool name, a timestamp, and a hash of the arguments (for privacy).

(Note: This is a placeholder for a more advanced analytics system in the future).
```

**Configuration: `.claude/hooks/skill-rules.json`**
```json
{
  "skills": [
    {
      "name": "n8n-workflow-patterns",
      "triggers": ["n8n", "workflow", "automation", "integration", "api", "webhook"],
      "confidence_threshold": 0.75,
      "auto_activate": true
    },
    {
      "name": "postgres-expert",
      "triggers": ["postgresql", "database", "query", "migration", "schema", "sql"],
      "confidence_threshold": 0.8,
      "auto_activate": true
    },
    {
        "name": "devops-engineer",
        "triggers": ["docker", "kubernetes", "k8s", "deployment", "ci/cd", "eks"],
        "confidence_threshold": 0.8,
        "auto_activate": true
    }
  ]
}
```

**Beneficios:**
- Experiencia de usuario proactiva e inteligente.
- Reducción de la necesidad de invocar skills manualmente.
- Routing eficiente a la herramienta correcta.

---

### 6. Documentación

**Gaps Identificados:**
- [ ] `CHANGELOG.md` (**Alta prioridad**) - Esencial para comunicar cambios a los usuarios.
- [ ] `CONTRIBUTING.md` (Media prioridad) - Clave para convertirlo en un proyecto de referencia para la comunidad.
- [ ] `TROUBLESHOOTING.md` (Media prioridad) - Mejorará la experiencia del usuario final.
- [ ] `COMMANDS_REFERENCE.md` (Media prioridad) - Documentación centralizada para todos los slash commands.

**Mejoras a Documentación Existente:**
- **README.md:** Añadir badges (versión, licencia), una lista más completa de features y ejemplos de uso.
- **docs/AGENTS_REFERENCE.md, etc:** Asegurarse de que estén sincronizados con los resultados de esta optimización (ej. agentes convertidos a skills).

---

### 7. Templates & Resources

**Templates a Añadir:**
1.  `eslint.config.js` - Template para una configuración de ESLint estricta. (ALTA)
2.  `jest.config.ts` - Template para la configuración de Jest con `ts-jest`. (MEDIA)
3.  `github-action.yml` - Template para un workflow básico de CI/CD (lint, test). (ALTA)

**Templates a Mejorar:**
- Los templates existentes son de alta calidad. No se requieren mejoras urgentes.

---

### 8. MCP Integration Expansion

**MCP Servers Recomendados a Documentar:**
- **GitHub MCP:** Para interactuar con repositorios, issues y pull requests. Esencial para un plugin de desarrollo.
- **PostgreSQL MCP:** Para ejecutar queries de solo lectura y analizar esquemas de bases de datos directamente.
- **Docker MCP:** Para gestionar contenedores y servicios, muy relevante para el stack del proyecto.

---

### 9. Security & Quality Improvements

**Critical Security Items:**
- No se encontraron vulnerabilidades críticas. El `.gitignore` es robusto.

**Quality Improvements:**
- **Estandarizar Comandos:** El plan de refactor de comandos (Sección 1) es la principal mejora de calidad.
- **TypeScript Strict en Templates:** La mayoría de los templates ya lo hacen, pero se debe verificar en los nuevos.
- **ESLint/Prettier Integration:** Añadir templates para `eslint.config.js` y `prettier.config.js` facilitará la consistencia del código.

---

## 🎯 Plan de Implementación

### Fase 1: Quick Wins (Alta Prioridad, 1-2 días)
**Objetivo:** Mejoras de alto impacto y bajo esfuerzo.
- [ ] Optimizar `CLAUDE.md` a la nueva estructura propuesta (< 100 líneas).
- [ ] Crear `CHANGELOG.md` y añadir una entrada inicial para v1.0.0.
- [ ] Mejorar `README.md` con badges y una lista de features más detallada.
- [ ] Refactorizar el comando `/store-new` para alinearlo con los criterios de "production-ready".

**Esfuerzo:** 8-12 horas | **Impacto:** Alto

---

### Fase 2: Skill System Enhancement (Alta Prioridad, 3-5 días)
**Objetivo:** Implementar el sistema de auto-activación y refactorizar los skills más críticos.
- [ ] Crear los 3 archivos del sistema de hooks (`skill-activation-prompt.md`, `post-tool-use-tracker.md`, `skill-rules.json`).
- [ ] Convertir los 4 agentes identificados a skills.
- [ ] Refactorizar los 3 skills más largos (ej. `n8n-node-configuration`, `n8n-code-python`, `n8n-code-javascript`) a un patrón de progressive disclosure.

**Esfuerzo:** 20-30 horas | **Impacto:** Muy Alto

---

### Fase 3: Templates & Documentation (Media Prioridad, 2-3 días)
**Objetivo:** Completar el ecosistema de templates y documentación.
- [ ] Añadir los 3 templates críticos (`github-action.yml`, `eslint.config.js`, `jest.config.ts`).
- [ ] Crear `CONTRIBUTING.md` y `TROUBLESHOOTING.md`.
- [ ] Actualizar toda la documentación en `docs/` para reflejar los cambios.

**Esfuerzo:** 12-18 horas | **Impacto:** Medio-Alto

---

### Fase 4: MCP Integration (Media Prioridad, 1-2 días)
**Objetivo:** Expandir las capacidades del plugin con más integraciones MCP.
- [ ] Investigar y documentar el setup para GitHub MCP, PostgreSQL MCP, y Docker MCP.
- [ ] Actualizar `MCP-SERVERS.md` con las nuevas guías.

**Esfuerzo:** 6-10 horas | **Impacto:** Medio

---

### Fase 5: Command & Skill Refinement (Baja-Media Prioridad, 2-4 días)
**Objetivo:** Refinar el resto de comandos y skills.
- [ ] Refactorizar los comandos con score < 4/5.
- [ ] Aplicar progressive disclosure al resto de skills largos.
- [ ] Añadir más ejemplos en cada comando y skill.

**Esfuerzo:** 15-25 horas | **Impacto:** Medio

---

### Fase 6: Advanced Features (Baja Prioridad, Futuro)
**Objetivo:** Features para una futura v2.0.0.
- [ ] Implementar un sistema de evaluación completo en `.claude/evaluations/`.
- [ ] Añadir telemetría de uso opt-in real.
- [ ] Optimización para el marketplace de plugins.

**Esfuerzo:** 40+ horas | **Impacto:** Variable

---

## 📈 Métricas de Éxito

### Antes de Optimización
- **CLAUDE.md:** 44 líneas
- **Skills > 500 líneas:** 7
- **Auto-activation:** No implementado
- **Comandos score < 4/5:** 5
- **Documentación Core:** Faltan `CHANGELOG.md`, `CONTRIBUTING.md`
- **Templates:** 5

### Después de Optimización (Target v1.3.0)
- **CLAUDE.md:** ~75 líneas
- **Skills > 500 líneas:** 0
- **Auto-activation:** ✅ Implementado
- **Comandos score < 4/5:** 0
- **Documentación Core:** Completa
- **Templates:** 8+

---

## 🚀 Recomendación Final

**Priorización Sugerida:**
1.  **Fase 1** (Quick Wins) - IMPLEMENTAR INMEDIATAMENTE
2.  **Fase 2** (Skill System) - LA MEJORA MÁS IMPACTANTE
3.  **Fase 3** (Templates & Docs) - PULIDO PROFESIONAL
4.  **Fase 4** (MCP) - EXPANSIÓN DEL ECOSISTEMA
5.  **Fase 5** (Refinement) - MEJORA CONTINUA
6.  **Fase 6** (Advanced) - VISIÓN A LARGO PLAZO

---

## ✅ Aprobación y Next Steps

**Propuesta Status:** PENDIENTE DE REVISIÓN

Para proceder con la implementación:
1.  Revisar esta propuesta completa.
2.  Aprobar las fases prioritarias.
3.  Crearé el branch: `optimization/anthropic-best-practices`.
4.  Comenzaré la implementación de forma incremental, solicitando revisión después de cada fase.
