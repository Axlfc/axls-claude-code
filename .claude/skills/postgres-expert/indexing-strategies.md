# PostgreSQL Indexing Strategies

Proper indexing is critical for query performance. This guide covers index types, design patterns, and optimization techniques.

## Index Types

### B-tree Indexes (Default)

General purpose indexes for equality and range comparisons.

```sql
-- Single column index
CREATE INDEX ON users(email);

-- Composite index (useful for multi-column filters)
CREATE INDEX ON users(status, created_at DESC);

-- Partial index (only index active records)
CREATE INDEX ON users(email) WHERE deleted_at IS NULL;

-- Expression index
CREATE INDEX ON products((lower(name))) WHERE active = true;

-- INCLUDE clause (PostgreSQL 11+) - index additional columns without sorting
CREATE INDEX ON orders(customer_id) INCLUDE (total_amount, status);
```

**When to Use:**
- Equality filters (`WHERE id = 123`)
- Range filters (`WHERE created_at > '2024-01-01'`)
- Sorting (`ORDER BY created_at`)
- Foreign keys (`customer_id`)

**Tradeoffs:**
- ✅ Flexible (many different query patterns)
- ❌ Slower for full-table scans
- ❌ Larger memory footprint

### Hash Indexes

For equality comparisons only. Rarely used in modern PostgreSQL.

```sql
CREATE INDEX ON users USING hash (email);
```

**Tradeoffs:**
- ✅ Faster for equality-only lookups
- ❌ Cannot be used for range queries
- ❌ Not crash-safe

### GiST Indexes

For geometric, range, and text search data.

```sql
-- Geometric type
CREATE INDEX ON locations USING gist (geom);

-- tsrange for temporal data
CREATE INDEX ON employee_history USING gist (valid_period);

-- Full-text search
CREATE INDEX ON documents USING gist (to_tsvector('english', content));
```

### GIN Indexes

For arrays, JSONB, and full-text search. Better than GiST for many use cases.

```sql
-- JSONB index
CREATE INDEX ON documents USING gin (data);

-- Array index
CREATE INDEX ON users USING gin (roles);

-- Full-text search (preferred over GiST)
CREATE INDEX ON articles USING gin (to_tsvector('english', content));

-- Multiple paths in JSONB
CREATE INDEX ON logs USING gin ((data->'fields') jsonb_path_ops);
```

**Tradeoffs:**
- ✅ Very fast for "contains" queries
- ✅ Great for JSONB and arrays
- ❌ Slower to build/maintain
- ❌ Larger index size

### BRIN Indexes

For very large tables with natural ordering.

```sql
-- Time-series data
CREATE INDEX ON events USING brin (created_at);

-- Large tables with ordered inserts
CREATE INDEX ON sensor_readings USING brin (timestamp) WITH (pages_per_range = 128);
```

**Tradeoffs:**
- ✅ Tiny index size (1% of data)
- ✅ Fast to build
- ❌ Less selective than B-tree
- ❌ Requires ordered data

## Index Design Patterns

### Composite Index Ordering

Order matters for composite indexes. General rule: equality first, then ranges/sorts.

```sql
-- Query patterns
SELECT * FROM orders 
WHERE customer_id = 123 
  AND created_at BETWEEN '2024-01-01' AND '2024-12-31'
ORDER BY total_amount DESC;

-- ✅ Good index order: customer_id (equality), created_at (range), total_amount (sort)
CREATE INDEX ON orders(customer_id, created_at, total_amount DESC);

-- Query with different filter order also uses this index
SELECT * FROM orders 
WHERE customer_id = 456 
  AND total_amount > 1000
ORDER BY created_at;
```

### Partial Indexes for Common Filters

Index only the rows you query most often.

```sql
-- Most queries filter by active records
CREATE INDEX ON users(email) WHERE deleted_at IS NULL;

-- Time-series data: recent data queried most
CREATE INDEX ON logs(level) WHERE created_at > NOW() - INTERVAL '30 days';

-- Status-specific queries
CREATE INDEX ON orders(customer_id) WHERE status = 'pending';
```

### Multi-column Indexes vs Single-column

```sql
-- ❌ Multiple single-column indexes
CREATE INDEX ON users(status);
CREATE INDEX ON users(created_at);

-- Better for queries using all columns
SELECT * FROM users 
WHERE status = 'active' 
  AND created_at > '2024-01-01';

-- ✅ Better: single composite index
DROP INDEX ON users(status);
DROP INDEX ON users(created_at);
CREATE INDEX ON users(status, created_at);
```

### Index-Only Scans (INCLUDE Clause)

Avoid accessing main table with INCLUDE clause.

```sql
-- Query: SELECT customer_id, total FROM orders WHERE id = ?
-- With INCLUDE, index has all needed data
CREATE INDEX ON orders(id) INCLUDE (customer_id, total);

-- Explain shows "Index Only Scan"
EXPLAIN SELECT customer_id, total FROM orders WHERE id = 12345;
```

## Index Maintenance

### Identify Unused Indexes

```sql
SELECT 
  schemaname,
  tablename,
  indexname,
  idx_scan,
  idx_tup_read,
  idx_tup_fetch,
  pg_size_pretty(pg_relation_size(indexrelid)) as index_size
FROM pg_stat_user_indexes
WHERE idx_scan = 0  -- Never used
ORDER BY pg_relation_size(indexrelid) DESC;

-- Drop unused indexes
DROP INDEX CONCURRENTLY IF EXISTS unused_index_name;
```

### Identify Bloated Indexes

```sql
SELECT 
  schemaname,
  tablename,
  indexname,
  pg_size_pretty(pg_relation_size(indexrelid)) as index_size,
  ROUND(100.0 * pg_relation_size(indexrelid) / 
    pg_relation_size(tablename::regclass)) as pct_of_table
FROM pg_stat_user_indexes
ORDER BY pg_relation_size(indexrelid) DESC;

-- Rebuild bloated index (locks table)
REINDEX INDEX CONCURRENTLY index_name;
```

### Index Statistics

```sql
-- Refresh statistics for index optimization
ANALYZE table_name;

-- Check index statistics
SELECT 
  schemaname,
  tablename, 
  indexname,
  idx_scan,
  idx_tup_read,
  idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;
```

## Index Tuning with EXPLAIN ANALYZE

### Sequential Scan (Bad)

```sql
EXPLAIN ANALYZE SELECT * FROM orders WHERE customer_id = 123;

-- Output shows:
-- Seq Scan on orders  (cost=0.00..5000.00 rows=100)
-- ↑ Full table scan - needs index!

CREATE INDEX ON orders(customer_id);

-- Now shows:
-- Index Scan using orders_customer_id_idx  (cost=0.29..4.32 rows=100)
-- ↑ Uses index - much better!
```

### Index Scan with Filter

```sql
EXPLAIN ANALYZE 
SELECT * FROM orders 
WHERE customer_id = 123 AND status = 'shipped';

-- If both columns queried, composite index better
CREATE INDEX ON orders(customer_id, status);

-- Composite index reduces filter rows
```

### Index-Only Scan (Best)

```sql
-- Query touches index only, not main table
EXPLAIN ANALYZE 
SELECT customer_id, total FROM orders WHERE id = 12345;

-- To achieve Index Only Scan:
CREATE INDEX ON orders(id) INCLUDE (customer_id, total);

-- Output shows:
-- Index Only Scan using orders_id_include_idx
-- ↑ Most efficient - never touches table!
```

## Common Anti-Patterns

### ❌ Index on Foreign Keys Without Checking Usage

```sql
-- Assumes FK is filtered often
CREATE INDEX ON orders(customer_id);
CREATE INDEX ON orders(product_id);

-- If these aren't filtered in queries, indexes waste space
```

### ✅ Index Based on Actual Queries

```sql
-- Check actual query patterns first
SELECT query, calls, total_time FROM pg_stat_statements 
WHERE query LIKE '%orders%'
ORDER BY total_time DESC;

-- Then create targeted indexes based on real queries
CREATE INDEX ON orders(customer_id) WHERE status IN ('pending', 'shipped');
```

### ❌ Too Many Indexes

```sql
-- Each index slows down INSERT/UPDATE/DELETE
CREATE INDEX ON users(email);
CREATE INDEX ON users(username);
CREATE INDEX ON users(status);
CREATE INDEX ON users(created_at);
CREATE INDEX ON users(deleted_at);

-- Maintenance and disk space suffers
```

### ✅ Composite Index for Related Queries

```sql
-- Single composite index covers multiple query patterns
CREATE INDEX ON users(status, created_at, email);

-- Works for:
-- WHERE status = 'active'
-- WHERE status = 'active' AND created_at > ?
-- WHERE status = 'active' ORDER BY created_at
```

## Performance Monitoring

### Slow Query Log

```sql
-- Find slow queries
SELECT 
  query,
  calls,
  total_time,
  mean_time,
  max_time
FROM pg_stat_statements
WHERE mean_time > 100  -- > 100ms average
ORDER BY total_time DESC
LIMIT 20;

-- Reset statistics
SELECT pg_stat_statements_reset();
```

### Index Performance

```sql
SELECT
  schemaname,
  tablename,
  indexname,
  idx_scan,
  idx_tup_read,
  idx_tup_fetch,
  CASE 
    WHEN idx_tup_fetch > 0 
    THEN ROUND(100.0 * (idx_tup_fetch - idx_tup_read) / idx_tup_fetch, 2)
    ELSE 0 
  END as efficiency_pct
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;
```

## Index Creation Best Practices

### Create Indexes Concurrently

```sql
-- Non-blocking index creation (does not lock table)
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);

-- Wait until complete before running conflicting queries
```

### Monitor Index Creation

```sql
-- Check long-running operations
SELECT pid, query, query_start 
FROM pg_stat_activity 
WHERE state != 'idle';

-- Cancel if needed
SELECT pg_cancel_backend(pid);
```

### Index Naming Convention

```sql
-- Clear, consistent naming
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_status_created ON orders(status, created_at);
CREATE INDEX idx_orders_customer_status ON orders(customer_id, status);
```

## Storage and Cost

### Estimate Index Size

```sql
SELECT 
  indexname,
  pg_size_pretty(pg_relation_size(indexrelid)) as index_size,
  pg_size_pretty(pg_total_relation_size(tablename::regclass)) as table_size
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY pg_relation_size(indexrelid) DESC;

-- If indexes > 50% of table size, review necessity
```
