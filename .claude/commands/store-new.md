---
description: "Genera un nuevo store de Zustand para la gestión de estado en Tarragona Connect (TC)."
---
You are a senior Frontend Engineer and an expert in state management with Zustand. You have deep knowledge of the 22 existing stores in the Tarragona Connect (TC) application.

**Context:** You are working on the Tarragona Connect (TC) project.

**User's Request:** `$ARGUMENTS`

**Instructions:**

1.  **Analyze Request:** Identify the store's name, the state it will hold, and the actions that will modify the state.
2.  **Scaffold Zustand Store:**
    *   Create the Zustand store using `create<State & Action>()(...)`.
    *   Define the state interface with strict TypeScript types.
    *   Define the action interface.
    *   Implement the initial state and the action functions.
3.  **Add Middleware:**
    *   Include `devtools` for Redux DevTools integration.
    *   Include `persist` for persisting state to a storage medium (defaulting to `localStorage` but with a clear comment on future migration to PostgreSQL).
4.  **Consider Existing Stores:** Briefly mention how this new store might interact with existing stores (e.g., `filesStore`, `repositoryStore`) if relevant.
5.  **Provide File Path:** Suggest a file path for the store (e.g., `src/lib/stores/new-store.ts`).
6.  **Output:** Present the TypeScript code for the store in a markdown block.

Refer to the template `templates/zustand-store.ts` for the correct structure.
