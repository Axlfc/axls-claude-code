# PostgreSQL Schema Design Guide

Designing a well-structured, normalized database schema is fundamental to long-term success. Poor schema design leads to performance problems, data integrity issues, and maintenance nightmares.

## Normalization Principles

### First Normal Form (1NF)
All attributes contain atomic (indivisible) values. No repeating groups.

**❌ Bad:**
```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  phone_numbers VARCHAR(500)  -- "555-1234, 555-5678" - not atomic!
);
```

**✅ Good:**
```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100)
);

CREATE TABLE phone_numbers (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  number VARCHAR(20)
);
```

### Second Normal Form (2NF)
No partial dependencies. All non-key attributes depend on the entire primary key.

**❌ Bad (for composite key):**
```sql
CREATE TABLE enrollments (
  student_id INTEGER,
  course_id INTEGER,
  student_name VARCHAR(100),  -- Depends only on student_id, not entire key
  PRIMARY KEY (student_id, course_id)
);
```

**✅ Good:**
```sql
CREATE TABLE enrollments (
  student_id INTEGER REFERENCES students(id),
  course_id INTEGER REFERENCES courses(id),
  enrollment_date DATE,
  grade VARCHAR(1),
  PRIMARY KEY (student_id, course_id)
);

-- student_name belongs in students table, not enrollments
```

### Third Normal Form (3NF)
No transitive dependencies. Non-key attributes depend only on the primary key.

**❌ Bad:**
```sql
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  customer_id INTEGER,
  customer_name VARCHAR(100),  -- Depends on customer_id
  customer_email VARCHAR(100),  -- Depends on customer_id
  created_at TIMESTAMP
);
```

**✅ Good:**
```sql
CREATE TABLE customers (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100)
);

CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  customer_id INTEGER REFERENCES customers(id),
  created_at TIMESTAMP
);
```

### Boyce-Codd Normal Form (BCNF)
For complex scenarios with multiple overlapping candidate keys. Usually overkill for application databases.

## Entity-Relationship Modeling

### One-to-Many Relationships

**Pattern:**
```sql
CREATE TABLE authors (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

CREATE TABLE books (
  id SERIAL PRIMARY KEY,
  author_id INTEGER NOT NULL REFERENCES authors(id),
  title VARCHAR(255) NOT NULL,
  isbn VARCHAR(13) UNIQUE,
  published_date DATE
);

CREATE INDEX ON books(author_id);
```

### Many-to-Many Relationships

**Pattern (with junction table):**
```sql
CREATE TABLE students (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100)
);

CREATE TABLE courses (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  code VARCHAR(10) UNIQUE
);

CREATE TABLE enrollments (
  student_id INTEGER REFERENCES students(id) ON DELETE CASCADE,
  course_id INTEGER REFERENCES courses(id) ON DELETE CASCADE,
  enrollment_date DATE DEFAULT CURRENT_DATE,
  grade VARCHAR(1),
  PRIMARY KEY (student_id, course_id)
);

CREATE INDEX ON enrollments(student_id);
CREATE INDEX ON enrollments(course_id);
```

### Self-Referential Relationships

**Example (organizational hierarchy):**
```sql
CREATE TABLE employees (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  manager_id INTEGER REFERENCES employees(id),
  department VARCHAR(50)
);

-- Query hierarchy
WITH RECURSIVE org_hierarchy AS (
  SELECT id, name, manager_id, 1 AS level
  FROM employees
  WHERE manager_id IS NULL  -- Root (CEO)
  
  UNION ALL
  
  SELECT e.id, e.name, e.manager_id, h.level + 1
  FROM employees e
  INNER JOIN org_hierarchy h ON e.manager_id = h.id
)
SELECT * FROM org_hierarchy ORDER BY level, id;
```

## Constraint Strategies

### Primary Keys

```sql
-- Simple surrogate key (recommended for most cases)
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE
);

-- Composite natural key
CREATE TABLE order_items (
  order_id INTEGER REFERENCES orders(id),
  item_sequence INTEGER,
  product_id INTEGER REFERENCES products(id),
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  PRIMARY KEY (order_id, item_sequence)
);

-- UUID for distributed systems
CREATE TABLE events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_type VARCHAR(100),
  payload JSONB
);
```

### Foreign Key Constraints

```sql
-- Basic foreign key
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  customer_id INTEGER NOT NULL REFERENCES customers(id)
);

-- With DELETE cascade (data gets deleted with parent)
CREATE TABLE order_items (
  id SERIAL PRIMARY KEY,
  order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE
);

-- With DELETE set null (orphan records)
CREATE TABLE comments (
  id SERIAL PRIMARY KEY,
  post_id INTEGER REFERENCES posts(id) ON DELETE SET NULL
);

-- With DELETE restrict (prevent deletion)
CREATE TABLE inventory (
  id SERIAL PRIMARY KEY,
  product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT
);
```

### CHECK Constraints

```sql
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  price NUMERIC(10, 2) CHECK (price > 0),
  quantity INTEGER CHECK (quantity >= 0),
  status VARCHAR(20) CHECK (status IN ('active', 'inactive', 'archived')),
  weight_kg NUMERIC(8, 2) CHECK (weight_kg > 0)
);
```

### UNIQUE Constraints

```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  username VARCHAR(100) NOT NULL UNIQUE,
  deleted_at TIMESTAMP
);

-- Partial unique index (for soft deletes)
CREATE UNIQUE INDEX users_email_active ON users(email) 
WHERE deleted_at IS NULL;

-- Composite unique constraint
CREATE TABLE user_roles (
  user_id INTEGER NOT NULL REFERENCES users(id),
  role_id INTEGER NOT NULL REFERENCES roles(id),
  UNIQUE(user_id, role_id)
);
```

### NOT NULL Constraints

```sql
-- Mark required fields with NOT NULL
CREATE TABLE customers (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  phone VARCHAR(20),  -- Optional
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

## JSON/JSONB for Flexibility

For semi-structured data without sacrificing query ability:

```sql
CREATE TABLE documents (
  id SERIAL PRIMARY KEY,
  content JSONB NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Query nested JSON
SELECT id, content->>'title' as title FROM documents;

-- Index JSON field for performance
CREATE INDEX ON documents USING gin (content);

-- Query with operators
SELECT * FROM documents 
WHERE content @> '{"status": "active"}';

-- Contains all keys
SELECT * FROM documents 
WHERE content ?& ARRAY['name', 'email'];

-- Extract and aggregate
SELECT content->'user'->>'email', COUNT(*) 
FROM documents 
GROUP BY content->'user'->>'email';
```

## Temporal Data Patterns

### Range-Based Validity (Effective Dating)

```sql
CREATE TABLE employee_salaries (
  employee_id INTEGER NOT NULL,
  salary NUMERIC(10, 2) NOT NULL,
  valid_from DATE NOT NULL,
  valid_to DATE,
  created_at TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY (employee_id, valid_from)
);

-- Get current salary
SELECT salary FROM employee_salaries 
WHERE employee_id = 123 
  AND valid_from <= CURRENT_DATE 
  AND (valid_to IS NULL OR valid_to > CURRENT_DATE)
LIMIT 1;

-- Prevent overlapping ranges
CREATE UNIQUE INDEX employee_salary_no_overlap ON employee_salaries(
  employee_id, 
  tsrange(valid_from, valid_to, '[]')
) WHERE valid_to IS NOT NULL;
```

### Event Sourcing Pattern

```sql
CREATE TABLE events (
  id SERIAL PRIMARY KEY,
  aggregate_id UUID NOT NULL,  -- Entity ID
  event_type VARCHAR(100) NOT NULL,  -- e.g., 'UserCreated', 'OrderPlaced'
  event_version INT DEFAULT 1,
  payload JSONB NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  created_by VARCHAR(100)
);

CREATE UNIQUE INDEX ON events(aggregate_id, event_version);

-- Rebuild current state
SELECT aggregate_id, 
       jsonb_object_agg(event_type, payload ORDER BY event_version) as state
FROM events
WHERE aggregate_id = 'user-123'
GROUP BY aggregate_id;
```

## Performance-Conscious Design

### Use Natural Surrogate vs Composite Keys

```sql
-- ❌ Large composite key slows down joins/indexes
CREATE TABLE order_items (
  order_number VARCHAR(20),
  order_year INT,
  line_number INT,
  product_id INT,
  quantity INT,
  PRIMARY KEY (order_number, order_year, line_number)
);

-- ✅ Surrogate key + unique constraint
CREATE TABLE order_items (
  id BIGSERIAL PRIMARY KEY,
  order_id INT REFERENCES orders(id),
  product_id INT REFERENCES products(id),
  quantity INT,
  UNIQUE(order_id, product_id)
);
```

### Choose Data Types Wisely

```sql
CREATE TABLE products (
  id BIGINT PRIMARY KEY,  -- Use BIGINT for large tables
  name VARCHAR(255),  -- Avoid TEXT if VARCHAR length known
  sku VARCHAR(50) UNIQUE,  -- CHAR/VARCHAR for strings
  price NUMERIC(10, 2),  -- NUMERIC for money, not FLOAT
  weight_kg REAL,  -- REAL for rough values
  created_at TIMESTAMP WITH TIME ZONE,  -- Always use TZ
  is_active BOOLEAN,  -- BOOLEAN not 0/1
  attributes JSONB  -- Flexible structured data
);
```

## Documentation Pattern

```sql
COMMENT ON TABLE users IS 'Stores user account information';
COMMENT ON COLUMN users.email IS 'User email address, must be unique';
COMMENT ON COLUMN users.created_at IS 'Account creation timestamp, immutable';

-- View documentation
SELECT obj_description('users'::regclass);
```

## Security Pattern

```sql
-- Create restricted roles
CREATE ROLE app_read NOLOGIN;
CREATE ROLE app_write NOLOGIN;

-- Grant specific permissions
GRANT USAGE ON SCHEMA public TO app_read, app_write;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_read;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO app_write;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO app_write;

-- Row-level security for multi-tenant data
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON documents
  USING (tenant_id = current_user_id());
```
