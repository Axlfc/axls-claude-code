# Zustand Store Patterns

Proven patterns for building scalable, maintainable Zustand stores in Tarragona Connect.

## Basic Store Pattern

### Minimal Store

```typescript
import { create } from 'zustand';

interface Counter {
  count: number;
  increment: () => void;
  decrement: () => void;
}

export const useCounterStore = create<Counter>((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
  decrement: () => set((state) => ({ count: state.count - 1 })),
}));
```

### Normalized Data Pattern

Store complex data normalized to prevent duplication and improve updates.

```typescript
import { create } from 'zustand';

interface Document {
  id: string;
  title: string;
  content: string;
  authorId: string;
}

interface Author {
  id: string;
  name: string;
  email: string;
}

interface DocumentStore {
  // Normalized state
  documents: Record<string, Document>;
  authors: Record<string, Author>;
  selectedDocumentId: string | null;
  
  // Actions
  setDocuments: (docs: Document[]) => void;
  setAuthors: (authors: Author[]) => void;
  updateDocument: (id: string, updates: Partial<Document>) => void;
  selectDocument: (id: string) => void;
}

export const useDocumentStore = create<DocumentStore>((set) => ({
  documents: {},
  authors: {},
  selectedDocumentId: null,
  
  setDocuments: (docs) => set({
    documents: docs.reduce((acc, doc) => ({
      ...acc,
      [doc.id]: doc,
    }), {}),
  }),
  
  setAuthors: (authors) => set({
    authors: authors.reduce((acc, author) => ({
      ...acc,
      [author.id]: author,
    }), {}),
  }),
  
  updateDocument: (id, updates) => set((state) => ({
    documents: {
      ...state.documents,
      [id]: { ...state.documents[id], ...updates },
    },
  })),
  
  selectDocument: (id) => set({ selectedDocumentId: id }),
}));

// Selectors
export const selectAllDocuments = (state: DocumentStore) => 
  Object.values(state.documents);

export const selectSelectedDocument = (state: DocumentStore) =>
  state.selectedDocumentId 
    ? state.documents[state.selectedDocumentId]
    : null;

export const selectDocumentAuthor = (state: DocumentStore) => {
  const doc = selectSelectedDocument(state);
  return doc ? state.authors[doc.authorId] : null;
};
```

## Advanced Patterns

### Store with Computed State

```typescript
interface TodoStore {
  todos: Record<string, Todo>;
  
  // Computed derived state
  completedCount: number;
  totalCount: number;
  completionPercentage: number;
}

export const useTodoStore = create<TodoStore>((set, get) => ({
  todos: {},
  
  get completedCount() {
    return Object.values(get().todos).filter(t => t.completed).length;
  },
  
  get totalCount() {
    return Object.values(get().todos).length;
  },
  
  get completionPercentage() {
    const total = get().totalCount;
    return total === 0 ? 0 : (get().completedCount / total) * 100;
  },
}));

// Or use selector pattern (recommended)
export const selectCompletedCount = (state: TodoStore) =>
  Object.values(state.todos).filter(t => t.completed).length;

export const selectCompletionPercentage = (state: TodoStore) => {
  const total = Object.values(state.todos).length;
  const completed = selectCompletedCount(state);
  return total === 0 ? 0 : (completed / total) * 100;
};
```

### Store with Async Actions

```typescript
interface FetchState {
  data: Record<string, Item>;
  loading: boolean;
  error: string | null;
  
  fetchItems: (id: string) => Promise<void>;
}

export const useFetchStore = create<FetchState>((set) => ({
  data: {},
  loading: false,
  error: null,
  
  fetchItems: async (id: string) => {
    set({ loading: true, error: null });
    
    try {
      const response = await fetch(`/api/items/${id}`);
      if (!response.ok) throw new Error('Failed to fetch');
      
      const item = await response.json();
      set((state) => ({
        data: { ...state.data, [id]: item },
        loading: false,
      }));
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Unknown error',
        loading: false,
      });
    }
  },
}));
```

### Store with Temporal State (Undo/Redo)

```typescript
interface EditorState {
  content: string;
  history: string[];
  historyIndex: number;
  
  updateContent: (content: string) => void;
  undo: () => void;
  redo: () => void;
  canUndo: boolean;
  canRedo: boolean;
}

export const useEditorStore = create<EditorState>((set, get) => ({
  content: '',
  history: [''],
  historyIndex: 0,
  
  updateContent: (content) => set((state) => {
    // Remove future history if we diverge
    const newHistory = state.history.slice(0, state.historyIndex + 1);
    newHistory.push(content);
    
    return {
      content,
      history: newHistory,
      historyIndex: newHistory.length - 1,
    };
  }),
  
  undo: () => set((state) => {
    const newIndex = Math.max(0, state.historyIndex - 1);
    return {
      historyIndex: newIndex,
      content: state.history[newIndex],
    };
  }),
  
  redo: () => set((state) => {
    const newIndex = Math.min(state.history.length - 1, state.historyIndex + 1);
    return {
      historyIndex: newIndex,
      content: state.history[newIndex],
    };
  }),
  
  get canUndo() {
    return get().historyIndex > 0;
  },
  
  get canRedo() {
    return get().historyIndex < get().history.length - 1;
  },
}));
```

## Middleware Patterns

### Logging Middleware

```typescript
import { create } from 'zustand';
import { devtools } from 'zustand/middleware';

export const useStoreWithLogging = create<YourState>()(
  devtools(
    (set, get) => ({
      // Your store definition
    }),
    { name: 'YourStore' }
  )
);

// Or custom logging middleware
const loggerMiddleware = <T extends object>(
  config: StateCreator<T>
): StateCreator<T> =>
  (set, get, api) =>
    config(
      (args) => {
        console.log('State change:', args);
        set(args);
      },
      get,
      api
    );
```

### Persistence Middleware

```typescript
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export const usePersistedStore = create<YourState>()(
  persist(
    (set) => ({
      // Store definition
    }),
    {
      name: 'your-store-key',
      storage: localStorage, // or custom storage
      partialize: (state) => ({
        // Only persist these fields
        count: state.count,
      }),
      merge: (persistedState, currentState) => ({
        // Custom merge logic
        ...currentState,
        ...persistedState,
      }),
      version: 1,
      migrate: (persistedState, version) => {
        // Handle schema migrations
        if (version === 0) {
          return { ...persistedState, count: 0 };
        }
        return persistedState;
      },
    }
  )
);
```

### API Sync Middleware

```typescript
const createApiSyncMiddleware = 
  (apiUrl: string) => 
  <T extends object>(
    config: StateCreator<T>
  ): StateCreator<T> =>
  (set, get, api) => {
    const state = config(set, get, api);
    
    // Sync store changes to API
    api.subscribe(
      (state) => state,
      (newState) => {
        fetch(`${apiUrl}/sync`, {
          method: 'POST',
          body: JSON.stringify(newState),
        }).catch(console.error);
      }
    );
    
    return state;
  };
```

## Selector Composition

### Creating Reusable Selectors

```typescript
// Simple selectors
export const selectTodoById = (state: TodoStore, id: string) =>
  state.todos[id];

export const selectAllTodos = (state: TodoStore) =>
  Object.values(state.todos);

// Composed selectors
export const selectCompletedTodos = (state: TodoStore) =>
  selectAllTodos(state).filter(t => t.completed);

export const selectTodoStats = (state: TodoStore) => ({
  total: selectAllTodos(state).length,
  completed: selectCompletedTodos(state).length,
  pending: selectAllTodos(state).filter(t => !t.completed).length,
});

// Usage in components
function TodoStats() {
  const stats = useTodoStore((state) => selectTodoStats(state));
  
  return (
    <div>
      <p>Total: {stats.total}</p>
      <p>Completed: {stats.completed}</p>
      <p>Pending: {stats.pending}</p>
    </div>
  );
}
```

### Memoized Selectors

```typescript
import { useMemo } from 'react';

function TodoList() {
  const todos = useTodoStore((state) => selectAllTodos(state));
  
  // Memoize expensive computation
  const sortedTodos = useMemo(() => {
    return [...todos].sort((a, b) => a.dueDate - b.dueDate);
  }, [todos]);
  
  return (
    <ul>
      {sortedTodos.map(todo => (
        <li key={todo.id}>{todo.title}</li>
      ))}
    </ul>
  );
}
```

### Custom Hook Pattern

```typescript
// Create custom hooks for common selections
export const useTodos = () => useTodoStore((state) => selectAllTodos(state));
export const useCompletedTodos = () => useTodoStore((state) => selectCompletedTodos(state));
export const useTodoStats = () => useTodoStore((state) => selectTodoStats(state));

// Usage becomes cleaner
function TodoComponent() {
  const todos = useTodos();
  const stats = useTodoStats();
  
  // Component code
}
```

## Store Combination

### Combining Multiple Stores

```typescript
export const useCombinedStore = () => {
  const user = useUserStore((state) => state.user);
  const settings = useSettingsStore((state) => state.settings);
  const notifications = useNotificationStore((state) => state.notifications);
  
  return { user, settings, notifications };
};

// Or subscribe to multiple stores
function AppComponent() {
  const { user, settings, notifications } = useCombinedStore();
  
  // Component code
}
```

## Common Anti-Patterns to Avoid

### ❌ Deeply Nested State

```typescript
// Bad: Deep nesting causes update issues
const store = create(() => ({
  user: {
    profile: {
      personal: {
        name: 'John',
        email: 'john@example.com',
      },
    },
  },
}));
```

### ✅ Normalized State

```typescript
// Good: Flat structure with references
const store = create(() => ({
  users: {
    'user-1': {
      id: 'user-1',
      name: 'John',
      email: 'john@example.com',
    },
  },
}));
```

### ❌ Inline Selectors

```typescript
// Bad: Creates new function every render
function Component() {
  const name = useStore((state) => state.user.name);
  const email = useStore((state) => state.user.email);
}
```

### ✅ Extracted Selectors

```typescript
// Good: Reusable, consistent
const selectName = (state) => state.user.name;
const selectEmail = (state) => state.user.email;

function Component() {
  const name = useStore(selectName);
  const email = useStore(selectEmail);
}
```

### ❌ No Type Safety

```typescript
const store = create((set) => ({
  items: [],
  add: (item: any) => set({}),
}));
```

### ✅ Full Type Safety

```typescript
interface Item {
  id: string;
  name: string;
}

interface ItemStore {
  items: Item[];
  add: (item: Item) => void;
}

const store = create<ItemStore>((set) => ({
  items: [],
  add: (item) => set((state) => ({
    items: [...state.items, item],
  })),
}));
```
