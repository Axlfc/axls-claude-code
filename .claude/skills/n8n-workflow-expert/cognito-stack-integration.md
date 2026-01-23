# cognito-stack Integration Guide

Complete integration patterns for connecting n8n workflows with the cognito-stack ecosystem: Ollama (AI/LLM), Qdrant (vector database), and PostgreSQL (data persistence).

## Service Discovery

### Internal Service URLs

```
Ollama:     http://ollama:11434
Qdrant:     http://qdrant:6333
PostgreSQL: postgres://[user]:[password]@postgres:5432/[database]
```

These URLs work from within the Docker Compose network. From outside, adjust the hostname to the actual IP or domain.

## Ollama Integration

### Generate Text Embeddings

Create vector representations of text for semantic search and similarity matching.

**HTTP Request Node Configuration:**

```json
{
  "method": "POST",
  "url": "http://ollama:11434/api/embeddings",
  "headers": {
    "Content-Type": "application/json"
  },
  "body": {
    "model": "nomic-embed-text",
    "prompt": "{{ $node['Input'].json.text }}"
  }
}
```

**Response:**
```json
{
  "embedding": [0.123, 0.456, ..., 0.789],
  "model": "nomic-embed-text",
  "total_duration": 45000000
}
```

### Text Generation / Completion

Generate text using Ollama's chat or completion endpoints.

**Chat Completion:**

```json
{
  "method": "POST",
  "url": "http://ollama:11434/api/chat",
  "headers": {
    "Content-Type": "application/json"
  },
  "body": {
    "model": "mistral",
    "messages": [
      {
        "role": "system",
        "content": "You are a helpful assistant."
      },
      {
        "role": "user",
        "content": "{{ $node['Input'].json.prompt }}"
      }
    ],
    "stream": false,
    "temperature": 0.7
  }
}
```

**Response:**
```json
{
  "model": "mistral",
  "created_at": "2024-01-01T00:00:00Z",
  "message": {
    "role": "assistant",
    "content": "Generated response text..."
  },
  "done": true,
  "total_duration": 2500000000,
  "prompt_eval_count": 42,
  "eval_count": 128,
  "eval_duration": 1000000000
}
```

### Multi-Turn Conversation

Maintain conversation history for context-aware responses.

**Workflow Pattern:**

```
1. Get Conversation History from PostgreSQL
2. Build Messages Array (system + history + new message)
3. Call Ollama /api/chat
4. Store Response in PostgreSQL
5. Return to User
```

**PostgreSQL Schema:**

```sql
CREATE TABLE conversations (
  id SERIAL PRIMARY KEY,
  user_id UUID NOT NULL,
  conversation_id UUID NOT NULL,
  role VARCHAR(20) NOT NULL,  -- 'user' or 'assistant'
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  tokens_used INT,
  duration_ms INT
);

CREATE INDEX ON conversations(conversation_id, created_at);
```

**Code Node to Build Messages:**

```javascript
const history = $node['PostgreSQL Query'].json;

const messages = [
  {
    role: "system",
    content: "You are a helpful assistant with context from previous messages."
  }
];

// Add conversation history (last 10 messages for context)
history.slice(-10).forEach(msg => {
  messages.push({
    role: msg.role,
    content: msg.content
  });
});

// Add current user message
messages.push({
  role: "user",
  content: $node['Input'].json.message
});

return { messages };
```

## Qdrant Integration

### Store Vector Embeddings

Insert or update vectors with associated metadata.

**HTTP Request Node Configuration:**

```json
{
  "method": "PUT",
  "url": "http://qdrant:6333/collections/documents/points",
  "headers": {
    "Content-Type": "application/json"
  },
  "body": {
    "points": [
      {
        "id": "{{ $node['Generate UUID'].json.uuid }}",
        "vector": "{{ $node['Generate Embedding'].json.embedding }}",
        "payload": {
          "text": "{{ $node['Input'].json.text }}",
          "source": "{{ $node['Input'].json.source }}",
          "created_at": "{{ new Date().toISOString() }}",
          "metadata": "{{ $node['Input'].json.metadata }}"
        }
      }
    ]
  }
}
```

### Semantic Search in Qdrant

Find similar vectors using semantic similarity.

**HTTP Request Configuration:**

```json
{
  "method": "POST",
  "url": "http://qdrant:6333/collections/documents/points/search",
  "headers": {
    "Content-Type": "application/json"
  },
  "body": {
    "vector": "{{ $node['Get Query Embedding'].json.embedding }}",
    "limit": 5,
    "with_payload": true,
    "with_vectors": false
  }
}
```

**Response:**
```json
{
  "result": [
    {
      "id": "doc-123",
      "score": 0.92,
      "payload": {
        "text": "Similar document text...",
        "source": "document-source",
        "created_at": "2024-01-01T00:00:00Z"
      }
    },
    ...
  ]
}
```

### Workflow: Semantic Search with Context

```
1. Receive Query
2. Generate Query Embedding (Ollama)
3. Search Qdrant (top 5 similar)
4. Combine Results as Context
5. Call Ollama with Context
6. Store Conversation in PostgreSQL
```

**Combined Code Node:**

```javascript
const embedding = $node['Generate Embedding'].json.embedding;
const searchResults = $node['Qdrant Search'].json.result;
const context = searchResults
  .map(r => `[${r.score.toFixed(2)}] ${r.payload.text}`)
  .join('\n');

return {
  systemPrompt: `You are answering based on this context:\n${context}`,
  contextUsed: searchResults.length,
  averageScore: (searchResults.reduce((sum, r) => sum + r.score, 0) / searchResults.length).toFixed(2)
};
```

## PostgreSQL Integration

### Connection Configuration

**PostgreSQL Node Settings:**

```
Host: postgres
Port: 5432
Database: [your-database]
User: [your-user]
Password: [stored in secret]
```

### Common Queries

**Insert with Conflict Handling:**

```sql
INSERT INTO documents (id, text, embedding, created_at)
VALUES ($1, $2, $3, NOW())
ON CONFLICT (id) DO UPDATE
SET 
  text = EXCLUDED.text,
  embedding = EXCLUDED.embedding,
  updated_at = NOW()
RETURNING id, created_at;
```

**Batch Insert (Upsert):**

```sql
INSERT INTO vectors (id, embedding, metadata)
VALUES 
  ($1, $2::vector, $3::jsonb),
  ($4, $5::vector, $6::jsonb),
  ($7, $8::vector, $9::jsonb)
ON CONFLICT (id) DO UPDATE
SET 
  embedding = EXCLUDED.embedding,
  metadata = jsonb_set(vectors.metadata, '{updated_at}', to_jsonb(NOW()))
RETURNING id;
```

**Query with Filtering:**

```sql
SELECT * FROM documents
WHERE created_at > NOW() - INTERVAL '7 days'
  AND category = $1
ORDER BY created_at DESC
LIMIT 100;
```

### Storing Workflow Executions

Track all AI operations for audit and optimization.

**Schema:**

```sql
CREATE TABLE workflow_executions (
  id SERIAL PRIMARY KEY,
  workflow_id VARCHAR(100) NOT NULL,
  execution_started TIMESTAMP DEFAULT NOW(),
  execution_completed TIMESTAMP,
  status VARCHAR(20),  -- 'success', 'error', 'timeout'
  input_data JSONB,
  output_data JSONB,
  error_message TEXT,
  execution_ms INT,
  ollama_calls INT,
  qdrant_calls INT,
  tokens_used INT,
  cost_estimate NUMERIC(10, 4)
);

CREATE INDEX ON workflow_executions(workflow_id, execution_started);
CREATE INDEX ON workflow_executions(status) WHERE status = 'error';
```

### Audit Logging

Log all AI operations for compliance and debugging.

**Code Node:**

```javascript
const auditLog = {
  workflow_id: "{{ $workflow.id }}",
  operation: "semantic_search",
  user_id: "{{ $node['Input'].json.user_id }}",
  query: "{{ $node['Input'].json.query }}",
  results_count: "{{ $node['Qdrant Search'].json.result.length }}",
  execution_ms: "{{ Date.now() - $execution.started }}",
  timestamp: new Date().toISOString()
};

return auditLog;
```

**SQL Insert:**

```sql
INSERT INTO audit_logs (operation, user_id, details, created_at)
VALUES ($1, $2, $3::jsonb, NOW());
```

## Integration Patterns

### RAG (Retrieval-Augmented Generation)

Combine document search with AI generation for accurate, contextual responses.

```
Query
  ↓
Get Embedding (Ollama)
  ↓
Search Similar Docs (Qdrant)
  ↓
Combine Context
  ↓
Generate Response (Ollama)
  ↓
Store Result (PostgreSQL)
```

### Agent Loop

Autonomous agent that thinks, acts, and observes.

```
Initialize State
  ↓
Think (Ollama) → Generate Action
  ↓
Execute Action
  ↓
Observe Result
  ↓
Store Experience (PostgreSQL/Qdrant)
  ↓
Loop Until Done
```

### Knowledge Graph Builder

Extract and build relationships from documents.

```
Document
  ↓
Extract Entities & Relations (Ollama)
  ↓
Store in PostgreSQL (nodes/edges)
  ↓
Generate Embeddings (Ollama)
  ↓
Store in Qdrant (for similarity)
```

## Performance Optimization

### Batch Operations
- Insert 100-1000 vectors at once instead of individually
- Combine multiple Ollama calls into single batch
- Use PostgreSQL batch upsert for efficiency

### Caching
- Cache Ollama embeddings for same input
- Store Qdrant search results in PostgreSQL
- Implement TTL for cached results

### Concurrency
- Set Qdrant requests to concurrent (5-10)
- Batch Ollama calls to maximize throughput
- Limit PostgreSQL connections

### Cost Optimization
- Reuse embeddings (don't regenerate for same text)
- Use smaller models for fast operations
- Batch operations to reduce API calls
- Monitor token usage to track costs

## Error Handling

### Ollama Timeout
```
Call Ollama → [Timeout] → 
  Log to PostgreSQL → 
  Use Cached Response → 
  Alert Operations
```

### Qdrant Connection Error
```
Search Qdrant → [Connection Error] → 
  Fallback to PostgreSQL Full Text Search → 
  Log Error → 
  Retry
```

### PostgreSQL Lock Timeout
```
Insert → [Timeout] → 
  Wait 1-5 seconds → 
  Retry (max 3) → 
  Log and Alert
```

## Debugging

### Enable Verbose Logging

```json
{
  "method": "POST",
  "url": "http://ollama:11434/api/chat",
  "body": { ... },
  "options": {
    "timeout": 30000
  }
}
```

Then check logs in PostgreSQL `workflow_executions` table.

### Monitor Performance

```sql
SELECT 
  workflow_id,
  COUNT(*) as executions,
  AVG(execution_ms) as avg_time_ms,
  COUNT(CASE WHEN status = 'error' THEN 1 END) as errors,
  SUM(tokens_used) as total_tokens
FROM workflow_executions
WHERE execution_started > NOW() - INTERVAL '24 hours'
GROUP BY workflow_id
ORDER BY avg_time_ms DESC;
```
