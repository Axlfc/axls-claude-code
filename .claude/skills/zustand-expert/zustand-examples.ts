// Zustand Examples: Complete TypeScript Patterns and Tests

import { create } from 'zustand';
import { persist, devtools } from 'zustand/middleware';

// ============================================================================
// EXAMPLE 1: Basic Store with Selectors
// ============================================================================

interface TodoItem {
  id: string;
  title: string;
  completed: boolean;
  createdAt: Date;
}

interface TodoStore {
  todos: Record<string, TodoItem>;
  selectedId: string | null;
  
  // Actions
  addTodo: (title: string) => void;
  removeTodo: (id: string) => void;
  toggleTodo: (id: string) => void;
  selectTodo: (id: string) => void;
}

export const useTodoStore = create<TodoStore>()(
  devtools(
    persist(
      (set, get) => ({
        todos: {},
        selectedId: null,
        
        addTodo: (title) => {
          const id = crypto.randomUUID();
          set((state) => ({
            todos: {
              ...state.todos,
              [id]: {
                id,
                title,
                completed: false,
                createdAt: new Date(),
              },
            },
          }));
        },
        
        removeTodo: (id) => set((state) => {
          const { [id]: removed, ...rest } = state.todos;
          return {
            todos: rest,
            selectedId: state.selectedId === id ? null : state.selectedId,
          };
        }),
        
        toggleTodo: (id) => set((state) => ({
          todos: {
            ...state.todos,
            [id]: { ...state.todos[id], completed: !state.todos[id].completed },
          },
        })),
        
        selectTodo: (id) => set({ selectedId: id }),
      }),
      {
        name: 'todo-store',
        partialize: (state) => ({ todos: state.todos }),
      }
    ),
    { name: 'TodoStore' }
  )
);

// Selectors
export const selectAllTodos = (state: TodoStore) =>
  Object.values(state.todos);

export const selectCompletedTodos = (state: TodoStore) =>
  selectAllTodos(state).filter((t) => t.completed);

export const selectPendingTodos = (state: TodoStore) =>
  selectAllTodos(state).filter((t) => !t.completed);

export const selectSelectedTodo = (state: TodoStore) =>
  state.selectedId ? state.todos[state.selectedId] : null;

export const selectTodoStats = (state: TodoStore) => {
  const all = selectAllTodos(state);
  const completed = selectCompletedTodos(state).length;
  return {
    total: all.length,
    completed,
    pending: all.length - completed,
    completionPercentage: all.length === 0 ? 0 : (completed / all.length) * 100,
  };
};

// ============================================================================
// EXAMPLE 2: Store with Async Actions
// ============================================================================

interface User {
  id: string;
  name: string;
  email: string;
}

interface UserStore {
  users: Record<string, User>;
  loading: boolean;
  error: string | null;
  
  fetchUsers: () => Promise<void>;
  fetchUserById: (id: string) => Promise<void>;
  createUser: (user: Omit<User, 'id'>) => Promise<void>;
  updateUser: (id: string, updates: Partial<User>) => Promise<void>;
}

export const useUserStore = create<UserStore>()(
  devtools(
    (set, get) => ({
      users: {},
      loading: false,
      error: null,
      
      fetchUsers: async () => {
        set({ loading: true, error: null });
        try {
          const response = await fetch('/api/users');
          if (!response.ok) throw new Error('Failed to fetch users');
          
          const users = await response.json();
          const normalized = users.reduce(
            (acc: Record<string, User>, user: User) => ({
              ...acc,
              [user.id]: user,
            }),
            {}
          );
          
          set({ users: normalized, loading: false });
        } catch (error) {
          set({
            error: error instanceof Error ? error.message : 'Unknown error',
            loading: false,
          });
        }
      },
      
      fetchUserById: async (id) => {
        set({ loading: true, error: null });
        try {
          const response = await fetch(`/api/users/${id}`);
          if (!response.ok) throw new Error('Failed to fetch user');
          
          const user = await response.json();
          set((state) => ({
            users: { ...state.users, [user.id]: user },
            loading: false,
          }));
        } catch (error) {
          set({
            error: error instanceof Error ? error.message : 'Unknown error',
            loading: false,
          });
        }
      },
      
      createUser: async (user) => {
        try {
          const response = await fetch('/api/users', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(user),
          });
          
          if (!response.ok) throw new Error('Failed to create user');
          const newUser = await response.json();
          
          set((state) => ({
            users: { ...state.users, [newUser.id]: newUser },
          }));
        } catch (error) {
          set({
            error: error instanceof Error ? error.message : 'Unknown error',
          });
          throw error;
        }
      },
      
      updateUser: async (id, updates) => {
        const original = get().users[id];
        
        // Optimistic update
        set((state) => ({
          users: {
            ...state.users,
            [id]: { ...state.users[id], ...updates },
          },
        }));
        
        try {
          const response = await fetch(`/api/users/${id}`, {
            method: 'PATCH',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(updates),
          });
          
          if (!response.ok) throw new Error('Failed to update user');
          const updated = await response.json();
          
          set((state) => ({
            users: { ...state.users, [id]: updated },
          }));
        } catch (error) {
          // Rollback optimistic update
          set((state) => ({
            users: { ...state.users, [id]: original },
            error: error instanceof Error ? error.message : 'Unknown error',
          }));
          throw error;
        }
      },
    }),
    { name: 'UserStore' }
  )
);

// ============================================================================
// EXAMPLE 3: Store with Custom Middleware
// ============================================================================

const apiSyncMiddleware = <T extends object>(
  config: (set: any, get: any, api: any) => T
): ((set: any, get: any, api: any) => T) => {
  return (set, get, api) => {
    const state = config(set, get, api);
    
    // Subscribe to all state changes and sync to API
    api.subscribe(
      (state: T) => state,
      (newState: T) => {
        // Debounce API calls
        clearTimeout(apiSyncMiddleware.timeout);
        apiSyncMiddleware.timeout = setTimeout(async () => {
          try {
            await fetch('/api/sync', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify(newState),
            });
          } catch (error) {
            console.error('Failed to sync state:', error);
          }
        }, 1000);
      }
    );
    
    return state;
  };
};

// ============================================================================
// EXAMPLE 4: Component Usage
// ============================================================================

// React component example
export function TodoComponent() {
  const todos = useTodoStore((state) => selectAllTodos(state));
  const stats = useTodoStore((state) => selectTodoStats(state));
  const { addTodo, toggleTodo, removeTodo } = useTodoStore();
  
  const [input, setInput] = React.useState('');
  
  const handleAdd = () => {
    if (input.trim()) {
      addTodo(input);
      setInput('');
    }
  };
  
  return (
    <div>
      <div>
        <input
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyPress={(e) => e.key === 'Enter' && handleAdd()}
          placeholder="Add a todo..."
        />
        <button onClick={handleAdd}>Add</button>
      </div>
      
      <div>
        <p>Total: {stats.total}</p>
        <p>Completed: {stats.completed}</p>
        <p>Progress: {stats.completionPercentage.toFixed(0)}%</p>
      </div>
      
      <ul>
        {todos.map((todo) => (
          <li key={todo.id}>
            <input
              type="checkbox"
              checked={todo.completed}
              onChange={() => toggleTodo(todo.id)}
            />
            <span style={{ textDecoration: todo.completed ? 'line-through' : 'none' }}>
              {todo.title}
            </span>
            <button onClick={() => removeTodo(todo.id)}>Delete</button>
          </li>
        ))}
      </ul>
    </div>
  );
}

// ============================================================================
// EXAMPLE 5: Unit Tests
// ============================================================================

describe('TodoStore', () => {
  beforeEach(() => {
    // Reset store before each test
    useTodoStore.setState({ todos: {}, selectedId: null });
  });
  
  it('should add a todo', () => {
    useTodoStore.getState().addTodo('Test todo');
    
    const todos = useTodoStore.getState().todos;
    expect(Object.keys(todos)).toHaveLength(1);
    expect(Object.values(todos)[0].title).toBe('Test todo');
  });
  
  it('should toggle todo completion', () => {
    useTodoStore.getState().addTodo('Test todo');
    const id = Object.keys(useTodoStore.getState().todos)[0];
    
    useTodoStore.getState().toggleTodo(id);
    expect(useTodoStore.getState().todos[id].completed).toBe(true);
    
    useTodoStore.getState().toggleTodo(id);
    expect(useTodoStore.getState().todos[id].completed).toBe(false);
  });
  
  it('should remove a todo', () => {
    useTodoStore.getState().addTodo('Test todo');
    const id = Object.keys(useTodoStore.getState().todos)[0];
    
    useTodoStore.getState().removeTodo(id);
    expect(useTodoStore.getState().todos).toEqual({});
  });
  
  it('should select a todo', () => {
    useTodoStore.getState().addTodo('Test todo');
    const id = Object.keys(useTodoStore.getState().todos)[0];
    
    useTodoStore.getState().selectTodo(id);
    expect(useTodoStore.getState().selectedId).toBe(id);
  });
  
  it('should calculate stats correctly', () => {
    useTodoStore.getState().addTodo('Todo 1');
    useTodoStore.getState().addTodo('Todo 2');
    useTodoStore.getState().addTodo('Todo 3');
    
    const ids = Object.keys(useTodoStore.getState().todos);
    useTodoStore.getState().toggleTodo(ids[0]);
    useTodoStore.getState().toggleTodo(ids[1]);
    
    const stats = useTodoStore.getState().selectTodoStats?.(useTodoStore.getState()) || 
                  selectTodoStats(useTodoStore.getState());
    
    expect(stats.total).toBe(3);
    expect(stats.completed).toBe(2);
    expect(stats.pending).toBe(1);
    expect(stats.completionPercentage).toBeCloseTo(66.67, 1);
  });
});

describe('UserStore', () => {
  beforeEach(() => {
    usUserStore.setState({ users: {}, loading: false, error: null });
  });
  
  it('should fetch users', async () => {
    global.fetch = jest.fn(() =>
      Promise.resolve({
        ok: true,
        json: () => Promise.resolve([
          { id: '1', name: 'John', email: 'john@example.com' },
          { id: '2', name: 'Jane', email: 'jane@example.com' },
        ]),
      })
    ) as jest.Mock;
    
    await useUserStore.getState().fetchUsers();
    
    const users = useUserStore.getState().users;
    expect(Object.keys(users)).toHaveLength(2);
    expect(users['1'].name).toBe('John');
  });
  
  it('should handle fetch error', async () => {
    global.fetch = jest.fn(() =>
      Promise.resolve({
        ok: false,
      })
    ) as jest.Mock;
    
    await useUserStore.getState().fetchUsers();
    
    expect(useUserStore.getState().error).toBeTruthy();
  });
  
  it('should create user optimistically', async () => {
    global.fetch = jest.fn(() =>
      Promise.resolve({
        ok: true,
        json: () => Promise.resolve({
          id: '1',
          name: 'New User',
          email: 'new@example.com',
        }),
      })
    ) as jest.Mock;
    
    await useUserStore.getState().createUser({
      name: 'New User',
      email: 'new@example.com',
    });
    
    const users = useUserStore.getState().users;
    expect(users['1']).toBeDefined();
    expect(users['1'].name).toBe('New User');
  });
});
