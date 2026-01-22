# Guía de Desarrollo con n8n

Este documento proporciona una guía detallada sobre cómo utilizar los skills y herramientas de n8n disponibles en este repositorio.

## Skills de n8n

Este proyecto incluye 7 skills expertos en n8n que se activan automáticamente para ayudarte a construir workflows robustos.

| Skill | Propósito |
|------|--------|
| `n8n-expression-syntax` | Uso correcto de expresiones `{{}}`, acceso a datos con `$json.body`, etc. |
| `n8n-mcp-tools-expert` | Cómo usar las herramientas del MCP como `search_nodes`, `get_node`, `validate_node`, etc. |
| `n8n-workflow-patterns` | 5 patrones probados: webhook, API HTTP, base de datos, IA y tareas programadas. |
| `n8n-validation-expert` | Interpretar y solucionar errores de validación; uso de `n8n_autofix_workflow`. |
| `n8n-node-configuration` | Configuración específica de operaciones para cada nodo (ej. `sendBody → contentType`). |
| `n8n-code-javascript` | Uso de JavaScript en los nodos de Código (`$input`, `$helpers`, etc.). |
| `n8n-code-python` | Uso de Python en los nodos de Código (limitado a la librería estándar). |

## Herramientas Clave del MCP de n8n

- `search_nodes` / `get_node` → Busca e inspecciona nodos.
- `n8n_create_workflow` / `n8n_update_partial_workflow` → Construye workflows de manera incremental.
- `n8n_validate_workflow` / `n8n_autofix_workflow` → Asegura que los workflows son correctos.
- `n8n_deploy_template` → Despliega workflows a partir de plantillas.
- `n8n_executions` → Monitoriza las ejecuciones de los workflows.

> 🧠 Recuerda: Los skills se activan automáticamente cuando tu solicitud coincide con su dominio. Por ejemplo, si preguntas "cómo accedo a los datos de un webhook en un nodo de Código", se activarán los skills `n8n-code-javascript` y `n8n-expression-syntax`.
