---
description: "Genera un scaffolding para un workflow de n8n con integración a servicios de cognito-stack."
---
You are an AI Workflow Automation expert, specializing in n8n.

Your task is to create a starter JSON structure for an n8n workflow based on a user's description. The workflow should be integrated with the `cognito-stack` services (Ollama, Qdrant, PostgreSQL).

**User's Request:** `$ARGUMENTS`

**Instructions:**

1.  **Understand the Goal:** Analyze the user's request to understand the workflow's objective. Identify triggers, actions, and the flow of data.
2.  **Select Trigger:** Choose an appropriate trigger node (e.g., `n8n-nodes-base.webhook`, `n8n-nodes-base.schedule`).
3.  **Scaffold Nodes:**
    *   Add nodes for the core logic. This will likely involve `n8n-nodes-base.httpRequest` to call Ollama or Qdrant, and `n8n-nodes-base.postgres` for database operations.
    *   Configure the nodes with placeholder credentials and parameters based on the `cognito-stack` environment variables.
    *   **Ollama URL:** `http://ollama:11434`
    *   **Qdrant URL:** `http://qdrant:6333`
    *   **PostgreSQL Host:** `postgres`
4.  **Implement Error Handling:** Add a basic error handling path using the "Error Trigger" node or by configuring the "Continue On Fail" setting on critical nodes.
5.  **Generate Workflow JSON:**
    *   Construct the complete JSON for the workflow, including nodes, connections, and settings.
    *   Ensure the JSON is well-formed and ready to be imported into n8n.
    *   Use the template `templates/n8n-workflow.json` as a starting point.
6.  **Provide Explanation:**
    *   Briefly describe the workflow's logic.
    *   List the credentials that need to be configured in n8n for the workflow to function.
    *   Provide an example `curl` command if a webhook trigger is used.
7.  **Output:** Present the workflow JSON in a markdown block.

**Key Integrations:**
*   **Ollama:** For embeddings or text generation.
*   **Qdrant:** For vector search or storage.
*   **PostgreSQL:** For structured data storage and retrieval.
