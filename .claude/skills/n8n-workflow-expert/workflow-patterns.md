# n8n Workflow Patterns

Proven architectural patterns for building efficient, maintainable n8n workflows. These patterns have been validated in production environments.

## Basic Webhook to Database Pattern

Most common pattern: receive data via webhook, validate, transform, and persist.

**Workflow Structure:**
```
Webhook Trigger → Validate Data → Transform → PostgreSQL Insert → Response
                      ↓ (error)
                  Send Alert
```

**Key Nodes:**
1. **Webhook:** Listen for HTTP POST, extract body
2. **Validation:** Check required fields, data types
3. **Code Node:** Transform data to database format
4. **PostgreSQL:** Insert with error handling
5. **Respond:** Return success/failure response

### Error Handling Pattern

```
Webhook → Process → PostgreSQL Insert
                          ↓ (on error)
                    Error Handler Node
                          ↓
                    Log to PostgreSQL
                          ↓
                    Notify via Slack
                          ↓
                    Return Error Response
```

**Error Handler Node Configuration:**
- Attached to all critical operations
- Logs error details to database
- Sends notification to operations team
- Returns appropriate HTTP status code

## AI Agent Workflow Pattern

Orchestrate multiple calls to Ollama for complex AI tasks with context management.

**Workflow Structure:**
```
Webhook (prompt) → 
  ↓
Get Context from Qdrant (semantic search) →
  ↓
Call Ollama with Context →
  ↓
Store Result in Qdrant (vector) →
  ↓
Persist to PostgreSQL (history) →
  ↓
Return Response
```

**Node Sequence:**

1. **Webhook Node:** Receive user prompt
2. **Qdrant Search:** Find similar past contexts
3. **Ollama Inference:** Generate response with context
4. **Qdrant Upsert:** Store new embedding
5. **PostgreSQL Insert:** Log conversation
6. **Response Node:** Return result

## Scheduled Batch Processing

Process large datasets on a schedule (hourly, daily, etc.).

**Workflow Structure:**
```
Scheduler (daily 2 AM) →
  ↓
PostgreSQL Query (fetch records) →
  ↓
Loop / Batch Process →
  ↓
Enrich with Ollama / Qdrant →
  ↓
Update PostgreSQL →
  ↓
Send Summary Email
```

**Optimization Tips:**
- Query in batches (e.g., 1000 records at a time)
- Use `Loop Over Items` node for parallel processing
- Limit Ollama/Qdrant calls with caching
- Update in bulk where possible
- Send summary notifications, not individual updates

## Event Streaming Pattern

React to events from various sources and fan-out to multiple destinations.

**Workflow Structure:**
```
Event Source (Webhook/Queue) →
  ↓
Parse & Validate Event →
  ↓
Enrich Event Data →
  ↓
Fan-Out:
  ├→ PostgreSQL (persistence)
  ├→ Qdrant (indexing)
  ├→ Slack (notification)
  ├→ Ollama (processing)
  └→ HTTP Webhook (external system)
```

**Implementation:**
- Use `Execute Once` for deduplication
- Implement idempotency keys
- Batch updates to Qdrant
- Rate limit Slack notifications
- Timeout external webhooks

## Retry and Backoff Pattern

Handle transient failures gracefully with exponential backoff.

```json
{
  "nodeType": "HTTP Request",
  "settings": {
    "url": "https://api.example.com/data",
    "method": "GET",
    "options": {
      "timeout": 30000,
      "retry": {
        "limit": 3,
        "maxBackoff": 60000,
        "randomization": true
      }
    }
  }
}
```

**Retry Configuration:**
- Start with 1-2 second delay
- Double delay on each retry
- Maximum of 3-5 retries
- Random jitter to avoid thundering herd
- Log each retry for debugging

## Conditional Branching Pattern

Different processing based on data characteristics or external state.

**Workflow Structure:**
```
Input →
  ├─ [Condition: urgent?] → Fast Path (Ollama)
  │
  ├─ [Condition: exists in DB?] → Update Path
  │
  └─ [Condition: else] → Create New Path
        ↓
    All Paths Merge → Response
```

**Implementation:**
- Use `IF` node for conditions
- Keep condition logic simple (extract to Code node if complex)
- Merge paths back together for response
- Log which path was taken

## Rate Limiting Pattern

Prevent overwhelming external services or hitting API limits.

```
Request Queue (wait) →
  ↓
Check Rate Limit Counter →
  ├─ [Below limit] → Execute
  │     ↓
  │   Increment Counter
  │     ↓
  │   Execute API Call
  │
  └─ [At limit] → Wait
        ↓
      Retry After Delay
```

**Implementation with PostgreSQL:**

```sql
-- Create rate limit table
CREATE TABLE rate_limits (
  id SERIAL PRIMARY KEY,
  service_name VARCHAR(100),
  count INT,
  reset_at TIMESTAMP,
  UNIQUE(service_name)
);

-- Check and increment
UPDATE rate_limits 
SET count = count + 1 
WHERE service_name = $1 
  AND reset_at > NOW()
RETURNING count;
```

## Deduplication Pattern

Prevent duplicate processing of idempotent operations.

```
Input →
  ↓
Generate Idempotency Key (hash input) →
  ↓
Check PostgreSQL (duplicate?) →
  ├─ [Found] → Return cached result
  │
  └─ [Not found] → Process
        ↓
      Store with Key →
      Execute Operation →
      Cache Result
```

**Implementation:**
- Use deterministic hash of input data
- Store key + result in PostgreSQL
- Check before processing
- Return cached result if exists
- Reduces API costs, improves latency

## Fan-Out / Fan-In Pattern

Process multiple items in parallel, then combine results.

```
Input List →
  ↓
Loop / Split Items →
  ↓
Parallel Processing:
  ├→ Enrichment A
  ├→ Enrichment B
  └→ Enrichment C
  ↓
Combine Results →
  ↓
Response
```

**Key Configuration:**
- Use `Loop Over Items` with parallel execution
- Set concurrency limit (e.g., 5 parallel)
- Collect all results
- Aggregate/combine results
- Handle partial failures gracefully

## Caching Pattern

Reduce API calls and improve performance with intelligent caching.

```
Request →
  ↓
Cache Key = hash(parameters) →
  ↓
Check PostgreSQL Cache Table →
  ├─ [Hit, not expired] → Return cached
  │
  └─ [Miss or expired] → 
      ↓
    Call External API →
    Store in Cache with TTL →
    Return Result
```

**Cache Table Schema:**

```sql
CREATE TABLE api_cache (
  key VARCHAR(255) PRIMARY KEY,
  value JSONB,
  created_at TIMESTAMP DEFAULT NOW(),
  expires_at TIMESTAMP,
  hits INT DEFAULT 0
);

-- Create index for cleanup
CREATE INDEX ON api_cache(expires_at) 
WHERE expires_at IS NOT NULL;
```

**Cache Duration Guidelines:**
- Static data: 24 hours
- User preferences: 1 hour
- Embedding vectors: 7 days
- Search results: 15 minutes
- Real-time data: no cache

## Common Anti-Patterns to Avoid

### ❌ No Error Handling
```
API Call → Database Insert → Response
```
**Problem:** One failure crashes entire workflow

### ✅ With Error Handling
```
API Call → [Error?] → Log & Alert
         → Database Insert → [Error?] → Log & Alert
         → Response
```

### ❌ Sequential When Could Be Parallel
```
Request A → Request B → Request C → Combine
```
**Problem:** Takes 3x time unnecessarily

### ✅ Parallel Processing
```
Request A ─┐
Request B ─┼→ Combine
Request C ─┘
```

### ❌ Unbounded Loop
```
Get ALL Records (10 million!) → Loop Process
```
**Problem:** Memory explosion, timeout

### ✅ Paginated Loop
```
Loop (page 1..100, batch 1000) → Process → Database Upsert
```

### ❌ No Timeout
```
HTTP Request (waits forever)
```
**Problem:** Workflow hangs

### ✅ With Timeout
```
HTTP Request (30s timeout) → Error Handler
```

## Performance Tips

1. **Batch Database Operations:** Use `INSERT ... ON CONFLICT` instead of individual inserts
2. **Minimize Ollama Calls:** Batch prompts, reuse embeddings
3. **Cache Qdrant Searches:** Store results, use TTL
4. **Parallel Execution:** Use Loop node's concurrency setting
5. **Reduce Data Payload:** Only send necessary fields
6. **Use Expressions Wisely:** Complex logic → Code node
7. **Monitor Execution Time:** Use `n8n-execution-time` metric

## Testing Patterns

See @testing-strategies.md for complete testing guidance.
