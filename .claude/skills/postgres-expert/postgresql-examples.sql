-- PostgreSQL Examples: Schemas, Migrations, Procedures
-- Complete, production-ready SQL examples

-- ============================================================================
-- SECTION 1: COMPLETE SCHEMA EXAMPLE (Multi-Tenant SaaS)
-- ============================================================================

-- Create schemas for organization
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS app;

-- Auth Schema: Users and authentication
CREATE TABLE auth.users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  email_verified BOOLEAN DEFAULT false,
  email_verified_at TIMESTAMP,
  mfa_enabled BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  deleted_at TIMESTAMP
);

CREATE INDEX idx_users_email ON auth.users(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_created_at ON auth.users(created_at);

-- App Schema: Multi-tenant application data
CREATE TABLE app.organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL REFERENCES auth.users(id),
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  plan VARCHAR(50) DEFAULT 'free',  -- free, pro, enterprise
  members_limit INT DEFAULT 5,
  storage_limit_gb INT DEFAULT 5,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  deleted_at TIMESTAMP
);

CREATE INDEX idx_orgs_owner_id ON app.organizations(owner_id);
CREATE INDEX idx_orgs_slug ON app.organizations(slug) WHERE deleted_at IS NULL;

-- Organization members
CREATE TABLE app.organization_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES app.organizations(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role VARCHAR(50) NOT NULL,  -- owner, admin, member
  joined_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(organization_id, user_id)
);

CREATE INDEX idx_org_members_org_id ON app.organization_members(organization_id);
CREATE INDEX idx_org_members_user_id ON app.organization_members(user_id);

-- Documents with versioning
CREATE TABLE app.documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES app.organizations(id) ON DELETE CASCADE,
  created_by UUID NOT NULL REFERENCES auth.users(id),
  title VARCHAR(255) NOT NULL,
  slug VARCHAR(255) NOT NULL,
  status VARCHAR(50) DEFAULT 'draft',  -- draft, published, archived
  content TEXT,
  metadata JSONB DEFAULT '{}',
  version INT DEFAULT 1,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  published_at TIMESTAMP,
  deleted_at TIMESTAMP,
  UNIQUE(organization_id, slug)
);

CREATE INDEX idx_docs_org_id ON app.documents(organization_id);
CREATE INDEX idx_docs_status ON app.documents(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_docs_published ON app.documents(published_at) WHERE published_at IS NOT NULL;
CREATE INDEX idx_docs_created_at ON app.documents(created_at);

-- Document audit trail
CREATE TABLE app.document_versions (
  id SERIAL PRIMARY KEY,
  document_id UUID NOT NULL REFERENCES app.documents(id) ON DELETE CASCADE,
  version_number INT NOT NULL,
  content TEXT NOT NULL,
  changed_by UUID NOT NULL REFERENCES auth.users(id),
  change_summary VARCHAR(500),
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(document_id, version_number)
);

CREATE INDEX idx_doc_versions_doc_id ON app.document_versions(document_id);

-- Comments with nested structure
CREATE TABLE app.comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id UUID NOT NULL REFERENCES app.documents(id) ON DELETE CASCADE,
  created_by UUID NOT NULL REFERENCES auth.users(id),
  parent_id UUID REFERENCES app.comments(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  resolved BOOLEAN DEFAULT false,
  resolved_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_comments_doc_id ON app.comments(document_id);
CREATE INDEX idx_comments_parent_id ON app.comments(parent_id);
CREATE INDEX idx_comments_created_by ON app.comments(created_by);

-- ============================================================================
-- SECTION 2: MIGRATION EXAMPLES
-- ============================================================================

-- Migration 1: Add column with default (safe, non-blocking)
ALTER TABLE app.documents 
ADD COLUMN is_featured BOOLEAN DEFAULT false;

CREATE INDEX idx_docs_featured ON app.documents(is_featured) 
WHERE is_featured = true;

-- Migration 2: Rename column (PostgreSQL 10+)
ALTER TABLE app.documents RENAME COLUMN slug TO url_slug;

-- Migration 3: Change column type with validation
ALTER TABLE app.comments 
ALTER COLUMN content TYPE TEXT USING content::TEXT,
ALTER COLUMN content SET NOT NULL;

-- Migration 4: Add constraint
ALTER TABLE app.organization_members 
ADD CONSTRAINT valid_role CHECK (role IN ('owner', 'admin', 'member', 'viewer'));

-- Migration 5: Create new table for feature flag configuration
CREATE TABLE app.feature_flags (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  organization_id UUID REFERENCES app.organizations(id) ON DELETE CASCADE,
  enabled BOOLEAN DEFAULT false,
  rollout_percentage INT DEFAULT 100 CHECK (rollout_percentage BETWEEN 0 AND 100),
  config JSONB DEFAULT '{}',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_flags_org_id ON app.feature_flags(organization_id, enabled);

-- Migration 6: Add column and populate from existing data
BEGIN;

ALTER TABLE app.documents ADD COLUMN word_count INT DEFAULT 0;

UPDATE app.documents 
SET word_count = array_length(string_to_array(content, ' '), 1)
WHERE content IS NOT NULL;

ALTER TABLE app.documents ALTER COLUMN word_count DROP DEFAULT;
CREATE INDEX idx_docs_word_count ON app.documents(word_count) 
WHERE word_count > 0;

COMMIT;

-- ============================================================================
-- SECTION 3: STORED PROCEDURES
-- ============================================================================

-- Function: Soft delete with cascade
CREATE OR REPLACE FUNCTION app.soft_delete_document(doc_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE app.documents 
  SET deleted_at = NOW() 
  WHERE id = doc_id AND deleted_at IS NULL;
  
  -- Cascade soft delete to comments
  UPDATE app.comments 
  SET deleted_at = NOW() 
  WHERE document_id = doc_id AND deleted_at IS NULL;
END;
$$ LANGUAGE plpgsql;

-- Function: Create new document version on update
CREATE OR REPLACE FUNCTION app.create_document_version()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.content IS DISTINCT FROM NEW.content THEN
    INSERT INTO app.document_versions (
      document_id, 
      version_number, 
      content, 
      changed_by,
      change_summary
    ) VALUES (
      NEW.id,
      NEW.version,
      OLD.content,
      CURRENT_USER_ID,  -- Requires auth context
      'Content updated'
    );
    
    NEW.version := NEW.version + 1;
    NEW.updated_at := NOW();
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- CREATE TRIGGER document_version_trigger
-- BEFORE UPDATE ON app.documents
-- FOR EACH ROW
-- EXECUTE FUNCTION app.create_document_version();

-- Function: Get user's documents with stats
CREATE OR REPLACE FUNCTION app.get_user_documents(user_id UUID, limit_val INT DEFAULT 50)
RETURNS TABLE (
  id UUID,
  title VARCHAR,
  status VARCHAR,
  comment_count BIGINT,
  last_version INT,
  created_at TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    d.id,
    d.title,
    d.status,
    COUNT(DISTINCT c.id),
    MAX(dv.version_number),
    d.created_at
  FROM app.documents d
  LEFT JOIN app.comments c ON d.id = c.document_id AND c.deleted_at IS NULL
  LEFT JOIN app.document_versions dv ON d.id = dv.document_id
  WHERE d.created_by = user_id AND d.deleted_at IS NULL
  GROUP BY d.id, d.title, d.status, d.created_at
  ORDER BY d.created_at DESC
  LIMIT limit_val;
END;
$$ LANGUAGE plpgsql STABLE;

-- Function: Calculate storage used by organization
CREATE OR REPLACE FUNCTION app.calculate_org_storage_used(org_id UUID)
RETURNS BIGINT AS $$
SELECT COALESCE(SUM(length(d.content)::BIGINT), 0)
FROM app.documents d
WHERE d.organization_id = org_id 
  AND d.deleted_at IS NULL;
$$ LANGUAGE SQL STABLE;

-- Function: Check if org has exceeded storage
CREATE OR REPLACE FUNCTION app.org_exceeds_storage_limit(org_id UUID)
RETURNS BOOLEAN AS $$
SELECT (
  app.calculate_org_storage_used(org_id) > 
  (SELECT storage_limit_gb * 1024 * 1024 * 1024 FROM app.organizations WHERE id = org_id)
);
$$ LANGUAGE SQL STABLE;

-- ============================================================================
-- SECTION 4: VIEWS FOR COMMON QUERIES
-- ============================================================================

-- View: User's accessible documents (respects permissions)
CREATE OR REPLACE VIEW app.user_accessible_documents AS
SELECT 
  d.id,
  d.organization_id,
  d.title,
  d.status,
  d.created_by,
  om.user_id as current_user_id,
  om.role as user_role,
  d.created_at,
  d.updated_at
FROM app.documents d
JOIN app.organizations o ON d.organization_id = o.id
JOIN app.organization_members om ON o.id = om.organization_id
WHERE d.deleted_at IS NULL
  AND o.deleted_at IS NULL
  AND om.user_id IS NOT NULL;

-- View: Organization statistics
CREATE OR REPLACE VIEW app.organization_stats AS
SELECT 
  o.id,
  o.name,
  COUNT(DISTINCT om.user_id) as member_count,
  COUNT(DISTINCT d.id) as document_count,
  COUNT(DISTINCT c.id) as comment_count,
  app.calculate_org_storage_used(o.id) as storage_used_bytes,
  o.storage_limit_gb * 1024 * 1024 * 1024 as storage_limit_bytes,
  o.created_at
FROM app.organizations o
LEFT JOIN app.organization_members om ON o.id = om.organization_id
LEFT JOIN app.documents d ON o.id = d.organization_id AND d.deleted_at IS NULL
LEFT JOIN app.comments c ON d.id = c.document_id AND c.deleted_at IS NULL
WHERE o.deleted_at IS NULL
GROUP BY o.id, o.name, o.storage_limit_gb, o.created_at;

-- ============================================================================
-- SECTION 5: ADVANCED QUERIES
-- ============================================================================

-- Get documents with comment activity in last 7 days
SELECT 
  d.id,
  d.title,
  d.status,
  COUNT(DISTINCT c.id) as recent_comments,
  MAX(c.created_at) as last_comment_at,
  d.updated_at
FROM app.documents d
LEFT JOIN app.comments c ON d.id = c.document_id 
  AND c.created_at > NOW() - INTERVAL '7 days'
  AND c.deleted_at IS NULL
WHERE d.deleted_at IS NULL
GROUP BY d.id, d.title, d.status, d.updated_at
HAVING COUNT(DISTINCT c.id) > 0
ORDER BY last_comment_at DESC;

-- Get user's activity timeline (last 30 days)
WITH user_activity AS (
  SELECT 
    user_id,
    'document_created' as activity_type,
    id as entity_id,
    created_at,
    title as description
  FROM app.documents
  WHERE deleted_at IS NULL AND created_at > NOW() - INTERVAL '30 days'
  
  UNION ALL
  
  SELECT 
    created_by,
    'comment_added',
    id,
    created_at,
    content
  FROM app.comments
  WHERE deleted_at IS NULL AND created_at > NOW() - INTERVAL '30 days'
)
SELECT * FROM user_activity
ORDER BY created_at DESC
LIMIT 100;

-- Find documents with declining engagement (fewer recent comments)
SELECT 
  d.id,
  d.title,
  COUNT(c.id) FILTER (WHERE c.created_at > NOW() - INTERVAL '30 days') as recent_comments,
  COUNT(c.id) FILTER (WHERE c.created_at > NOW() - INTERVAL '60 days' AND c.created_at <= NOW() - INTERVAL '30 days') as older_comments,
  CASE 
    WHEN COUNT(c.id) FILTER (WHERE c.created_at > NOW() - INTERVAL '60 days' AND c.created_at <= NOW() - INTERVAL '30 days') > 0
    THEN ROUND(100.0 * (COUNT(c.id) FILTER (WHERE c.created_at > NOW() - INTERVAL '30 days')::NUMERIC - 
               COUNT(c.id) FILTER (WHERE c.created_at > NOW() - INTERVAL '60 days' AND c.created_at <= NOW() - INTERVAL '30 days')) / 
               COUNT(c.id) FILTER (WHERE c.created_at > NOW() - INTERVAL '60 days' AND c.created_at <= NOW() - INTERVAL '30 days'), 2)
    ELSE 0
  END as engagement_change_pct
FROM app.documents d
LEFT JOIN app.comments c ON d.id = c.document_id AND c.deleted_at IS NULL
WHERE d.deleted_at IS NULL
GROUP BY d.id, d.title
HAVING COUNT(c.id) FILTER (WHERE c.created_at > NOW() - INTERVAL '60 days') > 0
ORDER BY engagement_change_pct ASC
LIMIT 20;

-- ============================================================================
-- SECTION 6: PERFORMANCE TUNING QUERIES
-- ============================================================================

-- Find unused indexes
SELECT 
  schemaname,
  tablename,
  indexname,
  idx_scan,
  pg_size_pretty(pg_relation_size(indexrelid)) as index_size
FROM pg_stat_user_indexes
WHERE idx_scan = 0
  AND schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY pg_relation_size(indexrelid) DESC;

-- Analyze table and index sizes
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname || '.' || tablename)) as total_size,
  pg_size_pretty(pg_relation_size(schemaname || '.' || tablename)) as table_size,
  ROUND(100.0 * pg_relation_size(schemaname || '.' || tablename) / 
        pg_total_relation_size(schemaname || '.' || tablename), 2) as table_pct
FROM pg_tables
WHERE schemaname IN ('app', 'auth')
ORDER BY pg_total_relation_size(schemaname || '.' || tablename) DESC;

-- Check table bloat
SELECT 
  schemaname,
  tablename,
  ROUND(100.0 * (pg_relation_size(schemaname || '.' || tablename) - 
                 pg_relation_size(schemaname || '.' || tablename, 'main')) / 
        pg_relation_size(schemaname || '.' || tablename), 2) as bloat_pct,
  pg_size_pretty(pg_relation_size(schemaname || '.' || tablename) - 
                 pg_relation_size(schemaname || '.' || tablename, 'main')) as bloat_size
FROM pg_tables
WHERE schemaname IN ('app', 'auth')
  AND pg_relation_size(schemaname || '.' || tablename) > 1000000;
