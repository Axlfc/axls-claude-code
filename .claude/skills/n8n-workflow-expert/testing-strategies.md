# n8n Testing Strategies

Comprehensive approach to testing n8n workflows before production deployment. Ensures reliability, performance, and data integrity.

## Unit Testing (Individual Nodes)

Test each node's configuration and transformations in isolation.

### Testing HTTP Requests

**What to Verify:**
- Request URL is correct
- Headers are properly formed
- Request body matches API expectations
- Response parsing works correctly
- Error responses are handled

**Manual Test Process:**

1. Create test workflow with single HTTP node
2. Configure with test data/parameters
3. Execute and validate response
4. Check response format matches expectations
5. Test error conditions (404, 500, timeout)

**Example Test Checklist:**

```markdown
- [ ] Request to correct URL
- [ ] Authentication headers present
- [ ] Request body valid JSON
- [ ] Response status 200
- [ ] Response contains expected fields
- [ ] Error response handled gracefully
- [ ] Timeout configured (30s)
- [ ] Retry logic present
```

### Testing Database Queries

**What to Verify:**
- Query syntax is correct
- Parameters bind properly
- Results return expected structure
- NULL values handled correctly
- Indexes used efficiently

**SQL Test Process:**

```sql
-- Test in PostgreSQL client first
SELECT * FROM documents 
WHERE user_id = 'test-user-123'
ORDER BY created_at DESC
LIMIT 10;

-- Verify results match workflow expectations
-- Check EXPLAIN for index usage
EXPLAIN ANALYZE SELECT * FROM documents 
WHERE user_id = 'test-user-123'
ORDER BY created_at DESC
LIMIT 10;
```

### Testing Code Node Expressions

**What to Verify:**
- JavaScript syntax correct
- Variable references valid
- Logic produces expected output
- Error conditions handled

**Test Approach:**

1. Test expression in isolation
2. Log inputs and outputs
3. Verify with sample data
4. Test edge cases (empty, null, large values)

**Example Expression Test:**

```javascript
// Test: Extract domain from email
const email = "user@example.com";
const domain = email.split('@')[1];
console.log(domain); // Output: example.com

// Test with edge cases
const emails = [
  "simple@domain.com",
  "with.dot+tag@sub.domain.co.uk",
  "invalid@",
  null
];

emails.forEach(email => {
  try {
    const domain = email.split('@')[1];
    console.log(`${email} → ${domain}`);
  } catch (e) {
    console.log(`${email} → ERROR: ${e.message}`);
  }
});
```

## Integration Testing (Node Interactions)

Test workflows with multiple nodes working together.

### Basic Webhook → Database Flow

**Test Scenario:**

1. Create test workflow with Webhook → Code → PostgreSQL nodes
2. Send sample JSON to webhook
3. Verify data appears in database
4. Check data integrity and format

**Test Request:**

```bash
curl -X POST http://localhost:5678/webhook/test-flow \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "test-123",
    "action": "login",
    "timestamp": "2024-01-01T12:00:00Z"
  }'
```

**Verification Query:**

```sql
SELECT * FROM workflow_executions 
WHERE id = (SELECT MAX(id) FROM workflow_executions)
LIMIT 1;
```

### Error Path Testing

**Test Scenario:**

1. Send invalid data
2. Verify error handler triggers
3. Check error logged to database
4. Confirm alert sent

**Test Invalid Request:**

```bash
curl -X POST http://localhost:5678/webhook/test-flow \
  -H "Content-Type: application/json" \
  -d '{
    "invalid": "structure"
  }'
```

**Verification:**

```sql
SELECT * FROM workflow_executions 
WHERE status = 'error'
ORDER BY execution_completed DESC
LIMIT 5;
```

## Load Testing

Validate workflow performance under load.

### Preparation

1. Set up test environment (staging)
2. Create test data (realistic volume)
3. Configure monitoring
4. Set performance baselines

### Load Test with Apache Bench

```bash
# Test 100 requests, 10 concurrent
ab -n 100 -c 10 \
  -H "Content-Type: application/json" \
  -p test-data.json \
  http://localhost:5678/webhook/test-flow

# Results show:
# - Requests per second
# - Response time (min/avg/max)
# - Failed requests
```

### Load Test with Artillery

```yaml
# artillery-load-test.yml
config:
  target: 'http://localhost:5678'
  phases:
    - duration: 60
      arrivalRate: 10
      name: 'Warm up'
    - duration: 300
      arrivalRate: 100
      name: 'Sustained load'

scenarios:
  - name: 'Webhook Test'
    flow:
      - post:
          url: '/webhook/test-flow'
          json:
            user_id: '{{ randomString(10) }}'
            action: 'test'
            timestamp: '{{ now }}'
```

**Run:**
```bash
artillery run artillery-load-test.yml
```

### Performance Baselines

**Establish Targets:**
- Response time < 1s (p95)
- Error rate < 0.1%
- Throughput > 100 req/s
- Database query < 100ms

**Track Over Time:**

```sql
CREATE TABLE performance_baselines (
  test_date DATE DEFAULT TODAY(),
  workflow_id VARCHAR(100),
  avg_response_time_ms INT,
  p95_response_time_ms INT,
  p99_response_time_ms INT,
  error_rate NUMERIC(5, 2),
  throughput_rps NUMERIC(8, 2),
  PRIMARY KEY (test_date, workflow_id)
);
```

## Data Validation Testing

Ensure data integrity through the workflow.

### Schema Validation

**Test Before Insert:**

```javascript
// Validate before database insert
const schema = {
  user_id: { type: 'string', required: true, minLength: 5 },
  email: { type: 'string', required: true, pattern: /^[^\s@]+@[^\s@]+\.[^\s@]+$/ },
  age: { type: 'number', min: 0, max: 150 },
  created_at: { type: 'string', required: true, format: 'iso8601' }
};

function validate(data, schema) {
  const errors = [];
  
  for (const [field, rules] of Object.entries(schema)) {
    const value = data[field];
    
    if (rules.required && (value === undefined || value === null)) {
      errors.push(`${field} is required`);
      continue;
    }
    
    if (value !== undefined && typeof value !== rules.type) {
      errors.push(`${field} must be ${rules.type}`);
    }
    
    if (rules.minLength && value?.length < rules.minLength) {
      errors.push(`${field} must be at least ${rules.minLength} chars`);
    }
    
    if (rules.pattern && !rules.pattern.test(value)) {
      errors.push(`${field} format invalid`);
    }
  }
  
  return { valid: errors.length === 0, errors };
}

const result = validate($node['Input'].json, schema);
return result;
```

### Test Cases

**Create comprehensive test cases:**

```javascript
const testCases = [
  {
    name: 'Valid complete record',
    data: {
      user_id: 'usr_12345',
      email: 'user@example.com',
      age: 25,
      created_at: new Date().toISOString()
    },
    shouldPass: true
  },
  {
    name: 'Missing required field',
    data: {
      email: 'user@example.com',
      age: 25
    },
    shouldPass: false
  },
  {
    name: 'Invalid email format',
    data: {
      user_id: 'usr_12345',
      email: 'invalid-email',
      age: 25,
      created_at: new Date().toISOString()
    },
    shouldPass: false
  },
  {
    name: 'Age out of range',
    data: {
      user_id: 'usr_12345',
      email: 'user@example.com',
      age: 200,
      created_at: new Date().toISOString()
    },
    shouldPass: false
  }
];

testCases.forEach(test => {
  const result = validate(test.data, schema);
  const passed = result.valid === test.shouldPass;
  console.log(`${test.name}: ${passed ? 'PASS' : 'FAIL'}`);
  if (!passed) {
    console.log(`  Expected: ${test.shouldPass}, Got: ${result.valid}`);
    console.log(`  Errors: ${result.errors.join(', ')}`);
  }
});
```

## Production Testing Checklist

Before deploying to production:

- [ ] All unit tests pass
- [ ] Integration tests with realistic data
- [ ] Error scenarios tested
- [ ] Load test shows acceptable performance
- [ ] Data validation working
- [ ] Database backups tested
- [ ] Monitoring alerts configured
- [ ] Logging enabled for debugging
- [ ] Timeouts appropriate
- [ ] Retry logic configured
- [ ] Rate limiting in place
- [ ] Documentation updated
- [ ] Team trained on workflow
- [ ] Rollback plan documented
- [ ] Staged rollout plan

## Continuous Testing

Implement ongoing testing to catch regressions.

### Automated Test Workflows

Create n8n workflows that test other workflows:

```
Scheduled Trigger (hourly)
  ↓
Load Test Data
  ↓
Execute Target Workflow
  ↓
Verify Results
  ↓
Log Results to PostgreSQL
  ↓
Alert if Failed
```

### Test Data Management

**Create realistic test datasets:**

```sql
-- Create test user
INSERT INTO test_data (user_id, scenario)
VALUES ('test_' || RANDOM()::text, 'basic_flow');

-- Verify after workflow execution
SELECT * FROM workflow_executions
WHERE input_data->>'user_id' LIKE 'test_%'
ORDER BY execution_completed DESC
LIMIT 10;
```

### Monitoring Dashboard

Track test results over time in Grafana:

```
- Test success rate (%)
- Average execution time (ms)
- P95/P99 latency
- Error categories
- Workflow health status
```
