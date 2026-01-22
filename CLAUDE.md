# Proyecto: axls-claude-code

Este repositorio contiene la infraestructura de un empleado de IA, diseñado para construir sistemas de IA que realizan trabajo real.

## Estilo de Código

- **TypeScript/JavaScript**: Sigue las guías de estilo de Airbnb. Usa Prettier para el formateo y ESLint para el análisis estático.
- **Python**: Sigue el estilo PEP 8. Usa Black para el formateo y Ruff para el análisis estático.
- **Commits**: Usa el estándar de [Conventional Commits](https://www.conventionalcommits.org/).

## Comandos Clave

- `npm install`: Instala las dependencias de Node.js.
- `npm run test`: Ejecuta los tests de Jest.
- `npm run lint`: Ejecuta el linter de ESLint.
- `ruff format .`: Formatea los ficheros de Python.
- `ruff check .`: Analiza los ficheros de Python con el linter.

## Arquitectura

- **`.claude/`**: Contiene la configuración principal del plugin, incluyendo `skills`, `commands` y `agents`.
- **`.claude-plugin/`**: Ficheros de configuración del plugin como `plugin.json` y `marketplace.json`.
- **`docs/`**: Documentación adicional y guías detalladas.
- **`templates/`**: Plantillas para la generación de código.

## Flujos de Trabajo (Routing)

| Si quieres... | Usa el skill |
|---|---|
| Crear un nuevo skill | `create-skill` |
| Crear un nuevo comando | `create-command` |
| Crear un nuevo agente | `create-agent` |
| Crear un nuevo hook | `create-hook` |
| Añadir o construir un MCP | `create-mcp` |

> Para una guía detallada sobre el desarrollo con n8n, consulta: @docs/n8n-guidelines.md

## Notas Importantes

- **Directorio de Trabajo**: Debes abrir la raíz de este repositorio directamente en tu editor. Si los `skills` o `agents` no funcionan, esta es la causa más común.
- **Salida de Ficheros**: Nunca generes ficheros en el directorio raíz. Las salidas deben ir en carpetas lógicas.
- **Servidores MCP**: Este proyecto está configurado para usar los servidores MCP de YouTube, Notion y n8n. Asegúrate de que estén correctamente configurados en tu fichero `.mcp.json`.
- **Configuración de Ollama**: Para usar Ollama, asegúrate de haber configurado las variables de entorno `ANTHROPIC_AUTH_TOKEN`, `ANTHROPIC_BASE_URL` y `ANTHROPIC_API_KEY` correctamente.
