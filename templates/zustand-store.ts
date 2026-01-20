// templates/zustand-store.ts
// Template for a Zustand store in Tarragona Connect.
// Includes middleware for devtools and persistence, with comments for future migration.

import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';

// 1. Define the state interface
interface MyStoreState {
  count: number;
  data: string | null;
  isLoading: boolean;
}

// 2. Define the actions interface
interface MyStoreActions {
  increment: () => void;
  fetchData: (id: string) => Promise<void>;
  reset: () => void;
}

// 3. Define the initial state
const initialState: MyStoreState = {
  count: 0,
  data: null,
  isLoading: false,
};

// 4. Create the store
export const useMyStore = create<MyStoreState & MyStoreActions>()(
  devtools(
    persist(
      (set, get) => ({
        ...initialState,

        // --- ACTIONS ---
        increment: () => set((state) => ({ count: state.count + 1 })),

        fetchData: async (id: string) => {
          set({ isLoading: true });
          try {
            // TODO: Replace localStorage logic with a call to the backend API.
            // Example:
            // const response = await fetch(`/api/data/${id}`);
            // const data = await response.json();
            // set({ data, isLoading: false });
            const mockData = `Data for ID: ${id}`;
            set({ data: mockData, isLoading: false });
          } catch (error) {
            console.error('Failed to fetch data', error);
            set({ isLoading: false, data: null });
          }
        },

        reset: () => set(initialState),
      }),
      {
        name: 'my-store-storage', // unique name
        // TODO: This persistence layer will be migrated to a backend API.
        // For now, it uses localStorage.
      }
    )
  )
);
