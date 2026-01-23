# Persistence Migration: localStorage → PostgreSQL

Strategic approach to migrating Tarragona Connect state persistence from localStorage to PostgreSQL backend while maintaining zero data loss and seamless user experience.

## Migration Strategy Overview

### Phase 1: Preparation (Weeks 1-2)
1. Design PostgreSQL schema for persisted state
2. Build API endpoints for state sync
3. Create dual-persistence middleware
4. Develop testing strategy

### Phase 2: Dual Write (Weeks 3-4)
1. Enable both localStorage and PostgreSQL writes
2. Monitor data consistency
3. Add fallback mechanisms
4. Test edge cases

### Phase 3: Migration (Weeks 5-6)
1. Gradually migrate users to database persistence
2. Monitor for issues
3. Provide rollback if needed

### Phase 4: Cleanup (Weeks 7+)
1. Remove localStorage fallback
2. Optimize database queries
3. Archive old data

## PostgreSQL Schema Design

```sql
-- Store definitions
CREATE TABLE store_schemas (
  id SERIAL PRIMARY KEY,
  store_name VARCHAR(100) NOT NULL UNIQUE,
  version INT DEFAULT 1,
  schema_definition JSONB NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Persisted state
CREATE TABLE store_state (
  id SERIAL PRIMARY KEY,
  user_id UUID NOT NULL,
  store_name VARCHAR(100) NOT NULL,
  state_data JSONB NOT NULL,
  last_synced_at TIMESTAMP DEFAULT NOW(),
  schema_version INT DEFAULT 1,
  UNIQUE(user_id, store_name),
  FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

CREATE INDEX idx_store_state_user_id ON store_state(user_id);
CREATE INDEX idx_store_state_synced_at ON store_state(last_synced_at);

-- Sync log for debugging
CREATE TABLE store_sync_log (
  id SERIAL PRIMARY KEY,
  user_id UUID NOT NULL,
  store_name VARCHAR(100),
  action VARCHAR(50),  -- 'load', 'save', 'conflict', 'error'
  status VARCHAR(50),  -- 'success', 'error'
  error_message TEXT,
  timestamp TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_sync_log_user_id ON store_sync_log(user_id, timestamp);
```

## Dual Persistence Implementation

### Hybrid Persistence Middleware

```typescript
import { StateCreator } from 'zustand';

interface PersistenceOptions {
  key: string;
  apiUrl: string;
  version: number;
}

const createHybridPersistence = 
  (options: PersistenceOptions) =>
  <T extends object>(
    config: StateCreator<T>
  ): StateCreator<T> =>
  (set, get, api) => {
    const state = config(set, get, api);
    
    // Load state from database, fall back to localStorage
    const loadState = async () => {
      try {
        // Try database first (preferred)
        const response = await fetch(`${options.apiUrl}/store/${options.key}`);
        if (response.ok) {
          const { state_data } = await response.json();
          return state_data;
        }
      } catch (error) {
        console.warn('Failed to load from DB, trying localStorage:', error);
      }
      
      // Fall back to localStorage
      try {
        const stored = localStorage.getItem(options.key);
        return stored ? JSON.parse(stored) : null;
      } catch (error) {
        console.error('Failed to load persisted state:', error);
        return null;
      }
    };
    
    // Save to both database and localStorage
    const saveState = async (newState: T) => {
      // Save to localStorage immediately (fast)
      try {
        localStorage.setItem(options.key, JSON.stringify(newState));
      } catch (error) {
        console.error('Failed to save to localStorage:', error);
      }
      
      // Save to database asynchronously (slow but persistent)
      try {
        await fetch(`${options.apiUrl}/store/${options.key}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            state_data: newState,
            schema_version: options.version,
          }),
        });
      } catch (error) {
        console.error('Failed to save to database:', error);
        // Continue anyway - localStorage is backup
      }
    };
    
    // Subscribe to state changes
    api.subscribe(
      (state) => state,
      (newState) => {
        saveState(newState).catch(console.error);
      }
    );
    
    // Initialize from storage
    loadState()
      .then((loaded) => {
        if (loaded) {
          set(loaded as Partial<T>);
        }
      })
      .catch(console.error);
    
    return state;
  };

export const createStore = <T extends object>(
  config: StateCreator<T>,
  options: PersistenceOptions
) => {
  return create<T>()(
    createHybridPersistence(options)(config)
  );
};
```

### Progressive Migration Approach

```typescript
interface MigrationConfig {
  migratedUserIds: Set<string>;
  migrationPercentage: number; // 0-100
}

const shouldUseDatabasePersistence = (
  userId: string,
  config: MigrationConfig
): boolean => {
  // Explicitly migrated users
  if (config.migratedUserIds.has(userId)) return true;
  
  // Percentage-based rollout
  const hash = hashUserId(userId);
  return (hash % 100) < config.migrationPercentage;
};

const createMigratingPersistence = 
  (options: PersistenceOptions & { migrationConfig: MigrationConfig }) =>
  <T extends object>(
    config: StateCreator<T>
  ): StateCreator<T> =>
  (set, get, api) => {
    const state = config(set, get, api);
    const userId = getCurrentUserId(); // From auth store
    
    const useDatabase = shouldUseDatabasePersistence(
      userId,
      options.migrationConfig
    );
    
    const saveState = async (newState: T) => {
      // Always save to localStorage (safety net)
      localStorage.setItem(options.key, JSON.stringify(newState));
      
      // Save to database if migrated
      if (useDatabase) {
        try {
          await fetch(`${options.apiUrl}/store/${options.key}`, {
            method: 'PUT',
            body: JSON.stringify({ state_data: newState }),
          });
        } catch (error) {
          console.error('Database save failed, using localStorage:', error);
        }
      }
    };
    
    const loadState = async () => {
      if (useDatabase) {
        try {
          const response = await fetch(`${options.apiUrl}/store/${options.key}`);
          if (response.ok) {
            const { state_data } = await response.json();
            return state_data;
          }
        } catch (error) {
          console.warn('Database load failed, using localStorage:', error);
        }
      }
      
      // Fall back to localStorage
      const stored = localStorage.getItem(options.key);
      return stored ? JSON.parse(stored) : null;
    };
    
    api.subscribe((state) => state, saveState);
    
    loadState().then((loaded) => {
      if (loaded) set(loaded);
    });
    
    return state;
  };
```

## API Endpoints

### Load Store State

```typescript
// GET /api/store/{storeName}
app.get('/api/store/:storeName', authenticate(), async (req, res) => {
  const { storeName } = req.params;
  const userId = req.user.id;
  
  const result = await db.query(
    'SELECT state_data, last_synced_at FROM store_state WHERE user_id = $1 AND store_name = $2',
    [userId, storeName]
  );
  
  if (result.rows.length === 0) {
    return res.status(404).json({ error: 'Store not found' });
  }
  
  res.json(result.rows[0]);
});
```

### Save Store State

```typescript
// PUT /api/store/{storeName}
app.put('/api/store/:storeName', authenticate(), async (req, res) => {
  const { storeName } = req.params;
  const { state_data, schema_version } = req.body;
  const userId = req.user.id;
  
  try {
    const result = await db.query(
      `INSERT INTO store_state (user_id, store_name, state_data, schema_version)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (user_id, store_name) DO UPDATE
       SET state_data = EXCLUDED.state_data,
           last_synced_at = NOW(),
           schema_version = EXCLUDED.schema_version
       RETURNING *`,
      [userId, storeName, JSON.stringify(state_data), schema_version]
    );
    
    // Log sync
    await db.query(
      'INSERT INTO store_sync_log (user_id, store_name, action, status) VALUES ($1, $2, $3, $4)',
      [userId, storeName, 'save', 'success']
    );
    
    res.json(result.rows[0]);
  } catch (error) {
    await db.query(
      'INSERT INTO store_sync_log (user_id, store_name, action, status, error_message) VALUES ($1, $2, $3, $4, $5)',
      [userId, storeName, 'save', 'error', error.message]
    );
    
    res.status(500).json({ error: 'Failed to save store state' });
  }
});
```

### Bulk Load All Stores

```typescript
// GET /api/stores (load all stores for user)
app.get('/api/stores', authenticate(), async (req, res) => {
  const userId = req.user.id;
  
  const result = await db.query(
    'SELECT store_name, state_data, last_synced_at FROM store_state WHERE user_id = $1',
    [userId]
  );
  
  const stores = result.rows.reduce((acc, row) => ({
    ...acc,
    [row.store_name]: {
      state: row.state_data,
      lastSynced: row.last_synced_at,
    },
  }), {});
  
  res.json(stores);
});
```

## Data Consistency & Conflict Resolution

### Detecting Conflicts

```typescript
interface StoreMeta {
  version: number;
  lastModified: number;
  hash: string;
}

const calculateHash = (state: any): string => {
  return crypto
    .createHash('sha256')
    .update(JSON.stringify(state))
    .digest('hex');
};

const hasConflict = (
  local: any,
  remote: any,
  localMeta: StoreMeta,
  remoteMeta: StoreMeta
): boolean => {
  // Different hashes = different content
  if (calculateHash(local) !== localMeta.hash) return true;
  if (calculateHash(remote) !== remoteMeta.hash) return true;
  return false;
};
```

### Conflict Resolution Strategy

```typescript
type ConflictResolution = 'local' | 'remote' | 'merge';

const resolveConflict = (
  local: any,
  remote: any,
  localTime: number,
  remoteTime: number,
  strategy: ConflictResolution
): any => {
  switch (strategy) {
    case 'local':
      return local;
    case 'remote':
      return remote;
    case 'merge':
      // For normalized data, merge objects
      if (typeof local === 'object' && typeof remote === 'object') {
        return {
          ...local,
          ...remote,
          // Newer values override
          ...(localTime > remoteTime ? local : remote),
        };
      }
      // Fall back to newer timestamp
      return localTime > remoteTime ? local : remote;
  }
};
```

## Schema Migrations

### Version Management

```typescript
interface SchemaMigration {
  version: number;
  migrate: (state: any) => any;
  description: string;
}

const migrations: SchemaMigration[] = [
  {
    version: 1,
    description: 'Initial schema',
    migrate: (state) => state,
  },
  {
    version: 2,
    description: 'Rename field from userId to user_id',
    migrate: (state) => ({
      ...state,
      user_id: state.userId,
      userId: undefined,
    }),
  },
  {
    version: 3,
    description: 'Normalize items array to record',
    migrate: (state) => ({
      ...state,
      items: Array.isArray(state.items)
        ? state.items.reduce((acc, item) => ({
            ...acc,
            [item.id]: item,
          }), {})
        : state.items,
    }),
  },
];

const applyMigrations = (state: any, fromVersion: number): any => {
  let currentState = state;
  
  for (const migration of migrations) {
    if (migration.version > fromVersion) {
      console.log(`Applying migration ${migration.version}: ${migration.description}`);
      currentState = migration.migrate(currentState);
    }
  }
  
  return currentState;
};
```

## Monitoring & Debugging

### Sync Health Dashboard

```typescript
interface SyncHealthMetric {
  storeName: string;
  lastSyncTime: number;
  successRate: number;
  avgSyncTime: number;
  lastError?: string;
}

const getSyncHealth = async (userId: string): Promise<SyncHealthMetric[]> => {
  const result = await db.query(`
    SELECT 
      store_name,
      MAX(timestamp) as last_sync_time,
      COUNT(*) FILTER (WHERE status = 'success') * 100.0 / COUNT(*) as success_rate,
      AVG(EXTRACT(EPOCH FROM timestamp - LAG(timestamp) OVER (PARTITION BY store_name ORDER BY timestamp))) as avg_sync_time,
      (array_agg(error_message ORDER BY timestamp DESC))[1] as last_error
    FROM store_sync_log
    WHERE user_id = $1
      AND timestamp > NOW() - INTERVAL '24 hours'
    GROUP BY store_name
  `, [userId]);
  
  return result.rows;
};
```

### Rollback Procedure

```typescript
const rollbackToLocalStorage = (storeName: string) => {
  // If database persistence fails, fall back to localStorage
  console.warn(`Rolling back ${storeName} to localStorage`);
  
  const stored = localStorage.getItem(storeName);
  if (stored) {
    try {
      const state = JSON.parse(stored);
      // Rehydrate store from localStorage
      useStore.setState(state);
      return true;
    } catch (error) {
      console.error('Rollback failed:', error);
      return false;
    }
  }
  
  return false;
};
```

## Testing Migration

### Test Cases

```typescript
describe('State Persistence Migration', () => {
  it('should load state from database if available', async () => {
    const state = await loadStateFromDatabase(userId, storeName);
    expect(state).toEqual(expectedState);
  });
  
  it('should fall back to localStorage if database unavailable', async () => {
    mockDatabaseFail();
    const state = await loadStateFromDatabase(userId, storeName);
    expect(state).toEqual(localStorageState);
  });
  
  it('should sync to both database and localStorage', async () => {
    await saveState(newState);
    expect(localStorage.getItem(key)).toBe(JSON.stringify(newState));
    expect(await getDatabaseState()).toEqual(newState);
  });
  
  it('should detect and resolve conflicts', () => {
    const resolved = resolveConflict(localState, remoteState, localTime, remoteTime, 'merge');
    expect(resolved).toEqual(expectedMerged);
  });
  
  it('should apply schema migrations', () => {
    const migrated = applyMigrations(oldState, 0);
    expect(migrated).toEqual(newState);
  });
});
```

## Rollout Plan

### Week 1-2: Preparation
- [ ] Create database schema
- [ ] Build API endpoints
- [ ] Implement dual-persistence middleware
- [ ] Write tests

### Week 3-4: Internal Testing
- [ ] Test with small user group (5%)
- [ ] Monitor sync logs
- [ ] Fix any issues

### Week 5-6: Gradual Rollout
- [ ] Enable for 10% of users
- [ ] Monitor success rate
- [ ] Increase to 25%, 50%, 100%

### Week 7+: Cleanup
- [ ] Remove localStorage-only code
- [ ] Archive old data
- [ ] Optimize database

## Monitoring Queries

```sql
-- Check sync status
SELECT 
  store_name,
  COUNT(*) as total_syncs,
  COUNT(*) FILTER (WHERE status = 'success') as successful,
  COUNT(*) FILTER (WHERE status = 'error') as failed,
  ROUND(100.0 * COUNT(*) FILTER (WHERE status = 'success') / COUNT(*), 2) as success_rate
FROM store_sync_log
WHERE timestamp > NOW() - INTERVAL '24 hours'
GROUP BY store_name
ORDER BY success_rate ASC;

-- Find problematic users
SELECT 
  user_id,
  COUNT(*) as total_errors,
  array_agg(DISTINCT error_message) as error_types
FROM store_sync_log
WHERE status = 'error'
  AND timestamp > NOW() - INTERVAL '24 hours'
GROUP BY user_id
HAVING COUNT(*) > 5
ORDER BY COUNT(*) DESC;
```
