# PostgreSQL Query Optimization

Master the art of writing efficient SQL queries that execute quickly and use minimal resources.

## Query Analysis with EXPLAIN ANALYZE

### Understanding EXPLAIN Output

```sql
EXPLAIN ANALYZE 
SELECT orders.id, customers.name, orders.total 
FROM orders 
JOIN customers ON orders.customer_id = customers.id 
WHERE orders.created_at > '2024-01-01'
ORDER BY orders.created_at DESC 
LIMIT 10;

/*
Limit  (cost=1234.56..1234.67 rows=10) (actual time=45.23..45.34 rows=10)
  ->  Sort  (cost=1234.56..5678.90 rows=5000) (actual time=45.22..45.33 rows=10)
        Sort Key: orders.created_at DESC
        ->  Hash Join  (cost=100.00..1000.00 rows=5000) (actual time=10.00..40.00 rows=5000)
              Hash Cond: (orders.customer_id = customers.id)
              ->  Seq Scan on orders  (cost=0.00..500.00 rows=10000) (actual time=0.10..8.00 rows=10000)
                    Filter: (created_at > '2024-01-01'::date)
                    Rows Removed by Filter: 990000
              ->  Hash  (cost=50.00..50.00 rows=1000) (actual time=0.50..0.50 rows=1000)
                    ->  Seq Scan on customers  (cost=0.00..50.00 rows=1000) (actual time=0.05..0.20 rows=1000)
Planning Time: 2.345 ms
Execution Time: 45.678 ms
*/
```

**Key Metrics:**
- **cost=**: PostgreSQL's estimate (arbitrary units)
- **rows=**: Expected rows (helps identify bad estimates)
- **actual time=**: Real execution time (ms)
- **Seq Scan**: Full table scan (bad for large tables)
- **Index Scan**: Using an index (good)
- **Index Only Scan**: Using index without table access (best)

### Improving Plan Quality

```sql
-- ❌ Bad: Sequential scans with poor filtering
EXPLAIN ANALYZE SELECT * FROM orders;
-- Seq Scan on orders  (cost=0.00..5000.00 rows=100000)

-- ✅ Better: Add filter and index
CREATE INDEX ON orders(created_at);
EXPLAIN ANALYZE SELECT * FROM orders WHERE created_at > '2024-01-01';
-- Index Scan using orders_created_at_idx  (cost=0.29..15.30 rows=500)
```

## Join Optimization

### Join Types

PostgreSQL uses different join algorithms based on data size and indexes:

```sql
-- NESTED LOOP: Small result sets, indexed joins
-- Hash Join: Large result sets, equality conditions
-- Merge Sort Join: Both sides sorted, good for large datasets

-- Example showing different join types
EXPLAIN SELECT * FROM orders o 
  JOIN customers c ON o.customer_id = c.id;

EXPLAIN SELECT * FROM orders o 
  JOIN customers c ON o.customer_id = c.id 
  JOIN products p ON o.product_id = p.id;
```

### Join Order Matters

```sql
-- Filter early to reduce rows before joins
-- ✅ Better: Filter customers first
SELECT o.id, o.total, c.name 
FROM orders o 
JOIN customers c ON o.customer_id = c.id 
WHERE c.status = 'active' 
  AND o.created_at > '2024-01-01';

-- With indexes
CREATE INDEX ON customers(status);
CREATE INDEX ON orders(customer_id, created_at);
```

### Multiple Joins

```sql
-- Optimal join order: most selective first
EXPLAIN SELECT o.*, c.name, p.name, i.quantity 
FROM orders o 
  JOIN customers c ON o.customer_id = c.id  -- Few customers
  JOIN order_items i ON o.id = i.order_id   -- All order items
  JOIN products p ON i.product_id = p.id;   -- Few products

-- Add these indexes
CREATE INDEX ON customers(id);
CREATE INDEX ON order_items(order_id);
CREATE INDEX ON products(id);
```

## Subquery Optimization

### Avoid Correlated Subqueries

```sql
-- ❌ Bad: Runs subquery for every outer row
SELECT o.id, 
       (SELECT SUM(amount) FROM payments p WHERE p.order_id = o.id) as total_paid
FROM orders o;

-- ✅ Better: Join (single scan)
SELECT o.id, COALESCE(SUM(p.amount), 0) as total_paid
FROM orders o 
LEFT JOIN payments p ON o.id = p.order_id
GROUP BY o.id;
```

### EXISTS vs IN

```sql
-- Both generally equivalent, but EXISTS better for large result sets
SELECT * FROM customers 
WHERE EXISTS (SELECT 1 FROM orders WHERE orders.customer_id = customers.id);

-- IN works for small result sets
SELECT * FROM customers 
WHERE id IN (SELECT customer_id FROM orders);
```

### Subquery in FROM vs JOIN

```sql
-- ❌ Subquery approach (harder to optimize)
SELECT c.name, derived.order_count
FROM customers c
JOIN (
  SELECT customer_id, COUNT(*) as order_count 
  FROM orders 
  GROUP BY customer_id
) derived ON c.id = derived.customer_id
WHERE derived.order_count > 5;

-- ✅ Better: Aggregate before join
SELECT c.name, COUNT(o.*) as order_count
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name
HAVING COUNT(o.*) > 5;
```

## Window Functions for Complex Analysis

```sql
-- Running total
SELECT id, amount,
       SUM(amount) OVER (ORDER BY created_at) as running_total
FROM transactions
ORDER BY created_at;

-- Rank within partition
SELECT employee_id, salary, department,
       RANK() OVER (PARTITION BY department ORDER BY salary DESC) as salary_rank
FROM employees;

-- Lead/lag for trend analysis
SELECT date, revenue,
       LAG(revenue) OVER (ORDER BY date) as prev_day_revenue,
       LEAD(revenue) OVER (ORDER BY date) as next_day_revenue,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY date)) / 
             LAG(revenue) OVER (ORDER BY date), 2) as pct_change
FROM daily_sales
ORDER BY date;
```

## Aggregation Optimization

### Partial Aggregates

```sql
-- ❌ Aggregate everything, then filter
SELECT department, AVG(salary)
FROM employees
GROUP BY department
HAVING COUNT(*) > 10;

-- ✅ Better: Filter before aggregation
SELECT department, AVG(salary)
FROM employees
WHERE hire_date > '2020-01-01'
GROUP BY department
HAVING COUNT(*) > 10;
```

### Materialized Views for Complex Aggregates

```sql
-- Complex aggregation used frequently
CREATE MATERIALIZED VIEW customer_stats AS
SELECT 
  c.id,
  c.name,
  COUNT(DISTINCT o.id) as order_count,
  SUM(o.total) as total_spent,
  AVG(o.total) as avg_order_value,
  MAX(o.created_at) as last_order_date
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name;

CREATE INDEX ON customer_stats(total_spent DESC);

-- Refresh when data changes
REFRESH MATERIALIZED VIEW customer_stats;

-- Query is now instant
SELECT * FROM customer_stats 
WHERE total_spent > 10000 
ORDER BY total_spent DESC;
```

## UNION vs UNION ALL

```sql
-- ❌ UNION removes duplicates (expensive)
SELECT id FROM products WHERE category = 'electronics'
UNION
SELECT id FROM products WHERE price > 1000;

-- ✅ UNION ALL if you don't care about duplicates
SELECT id FROM products WHERE category = 'electronics'
UNION ALL
SELECT id FROM products WHERE price > 1000;

-- Better: Single query
SELECT id FROM products 
WHERE category = 'electronics' OR price > 1000;
```

## Common Table Expressions (CTEs)

### Simplifying Complex Queries

```sql
-- Make logic clearer with CTEs
WITH recent_orders AS (
  SELECT id, customer_id, total, created_at
  FROM orders
  WHERE created_at > NOW() - INTERVAL '30 days'
),
high_value_customers AS (
  SELECT customer_id, COUNT(*) as order_count, SUM(total) as total_spent
  FROM recent_orders
  GROUP BY customer_id
  HAVING SUM(total) > 5000
)
SELECT c.name, h.order_count, h.total_spent
FROM customers c
JOIN high_value_customers h ON c.id = h.customer_id
ORDER BY h.total_spent DESC;
```

### Recursive CTEs for Hierarchies

```sql
-- Traverse organizational hierarchy
WITH RECURSIVE employee_hierarchy AS (
  -- Base case: root employees
  SELECT id, name, manager_id, 1 as level
  FROM employees
  WHERE manager_id IS NULL
  
  UNION ALL
  
  -- Recursive case: direct reports
  SELECT e.id, e.name, e.manager_id, eh.level + 1
  FROM employees e
  INNER JOIN employee_hierarchy eh ON e.manager_id = eh.id
  WHERE eh.level < 10  -- Prevent infinite recursion
)
SELECT * FROM employee_hierarchy
ORDER BY level, id;
```

## Data Type Implications

### Text Searching

```sql
-- ❌ LIKE with leading wildcard (no index)
SELECT * FROM products WHERE name LIKE '%shoes%';

-- ✅ Full-text search (indexed)
CREATE INDEX ON products USING gin (to_tsvector('english', name));
SELECT * FROM products 
WHERE to_tsvector('english', name) @@ to_tsquery('english', 'shoes');

-- ✅ LIKE without leading wildcard (index usable)
SELECT * FROM products WHERE name LIKE 'shoes%';
```

### JSON Queries

```sql
-- ❌ No index
SELECT * FROM documents WHERE data->>'category' = 'tech';

-- ✅ With GIN index
CREATE INDEX ON documents USING gin (data);
SELECT * FROM documents WHERE data @> '{"category": "tech"}';
```

## Batch Operations

### Bulk Insert

```sql
-- ❌ Slow: Individual inserts in transaction
BEGIN;
INSERT INTO products (name, price) VALUES ('A', 100);
INSERT INTO products (name, price) VALUES ('B', 200);
INSERT INTO products (name, price) VALUES ('C', 300);
COMMIT;

-- ✅ Fast: Batch insert
INSERT INTO products (name, price) VALUES
  ('A', 100),
  ('B', 200),
  ('C', 300);
```

### Bulk Update with CTE

```sql
-- Update multiple rows efficiently
UPDATE orders
SET status = 'shipped', shipped_at = NOW()
WHERE id IN (SELECT order_id FROM items WHERE quantity > 1000);

-- With CTE for clarity
WITH large_orders AS (
  SELECT DISTINCT order_id 
  FROM order_items 
  WHERE quantity > 1000
)
UPDATE orders
SET status = 'shipped', shipped_at = NOW()
WHERE id IN (SELECT order_id FROM large_orders);
```

## Common Performance Issues

### N+1 Query Problem

```sql
-- ❌ Bad: Multiple round trips
SELECT * FROM customers WHERE id = 1;
SELECT * FROM orders WHERE customer_id = 1;
SELECT * FROM payments WHERE order_id = 101;

-- ✅ Better: Single query with joins
SELECT c.*, o.*, p.*
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
LEFT JOIN payments p ON o.id = p.order_id
WHERE c.id = 1;
```

### Memory-Heavy Operations

```sql
-- ❌ Load entire dataset for sorting
SELECT * FROM large_table ORDER BY complex_calculation LIMIT 10;

-- ✅ Optimize before sorting
SELECT * FROM large_table 
WHERE index_filter_column = 'value'  -- Reduce rows first
ORDER BY indexed_column LIMIT 10;  -- Sort indexed column
```
