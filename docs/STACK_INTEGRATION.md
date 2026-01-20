# Integración con cognito-stack

Este documento explica cómo los Skills y Agentes de `axls-claude-code` están diseñados para interactuar directamente con la infraestructura de `cognito-stack`.

## Contexto de Servicios

Los Skills asumen que los siguientes servicios están disponibles en la red interna de Docker (`cognito_network`):

| Servicio | URL Interna | Descripción |
| :--- | :--- | :--- |
| **Ollama** | `http://ollama:11434` | Servicio de modelos de lenguaje local. |
| **Qdrant** | `http://qdrant:6333` | Base de datos de vectores. |
| **PostgreSQL**| `postgres:5432` | Base de datos relacional. |
| **Redis** | `redis:6379` | Almacén en memoria (caché, colas). |
| **n8n** | `http://n8n:5678` | Orquestador de workflows. |
| **Prometheus**| `http://prometheus:9090`| Sistema de monitoreo y alertas. |
| **Grafana** | `http://grafana:3000` | Plataforma de visualización de métricas. |

## Variables de Entorno

Muchos Skills, especialmente `/docker-service` y `/k8s-manifest`, dependen de un conjunto estándar de variables de entorno. Asegúrate de tener un archivo `.env` en tus proyectos basado en el siguiente formato:

```bash
# PostgreSQL
POSTGRES_DB=cognito_db
POSTGRES_USER=cognito_user
POSTGRES_PASSWORD=<secret>

# n8n
N8N_ENCRYPTION_KEY=<secret>
WEBHOOK_URL=https://n8n.cognito.local

# Ollama
OLLAMA_API_URL=http://ollama:11434
OLLAMA_MODEL_1=llama3.2

# Qdrant
QDRANT_URL=http://qdrant:6333
QDRANT_API_KEY=<secret>

# Observabilidad
SENTRY_DSN=<your-dsn>
```

## Ejemplos de Flujos de Trabajo

### Ejemplo 1: Crear un nuevo microservicio con monitoreo

1.  **Generar el servicio**: Usa `/docker-service` para crear el `Dockerfile` y el snippet de `docker-compose.yml`.
    > `/docker-service` "Servicio 'transcoder-service' basado en `python:3.10-slim` que expone el puerto 5000."
2.  **Añadir un endpoint**: Usa `/api-endpoint` para generar el código de la API (por ejemplo, en Fastify).
    > `/api-endpoint` "Endpoint POST /transcode para el transcoder-service."
3.  **Configurar Observabilidad**: Usa `/sentry-integration` para añadir Sentry. El `devops-engineer` podría sugerir añadir un endpoint de métricas para Prometheus.
4.  **Desplegar**: Una vez que el código esté listo, el `devops-engineer` puede ayudarte a generar los manifiestos de Kubernetes con `/k8s-manifest`.

### Ejemplo 2: Crear un workflow de IA en n8n

1.  **Scaffold del Workflow**: Usa `/new-workflow` para obtener la estructura base.
    > `/new-workflow` "Workflow que se activa por webhook, toma un texto, genera embeddings con Ollama y los guarda en Qdrant."
2.  **Refinar la Lógica**: El `n8n-workflow-expert` se activará para ayudarte a refinar la lógica, configurar los nodos HTTP para llamar a `http://ollama:11434` y `http://qdrant:6333`, y gestionar el flujo de datos.
3.  **Añadir Persistencia**: El `postgres-expert` puede ayudarte a añadir un paso al workflow para guardar metadatos en la base de datos PostgreSQL.
