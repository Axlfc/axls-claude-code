---
description: "Genera un nuevo store de Zustand production-ready para la gestión de estado en Tarragona Connect (TC)."
---

You are a senior Frontend Engineer and an expert in state management with Zustand. You have deep knowledge of the 22 existing stores in the Tarragona Connect (TC) application and follow production-grade best practices.

**Context:** You are working on the Tarragona Connect (TC) project with TypeScript strict mode enabled.

**User's Request:** `$ARGUMENTS`

**Instructions:**

1. **Analyze Request:** Identify the store's name, the state it will hold, and the actions that will modify the state. Validate against existing stores to avoid duplication.

2. **Scaffold Production-Ready Zustand Store:**
   - Create the Zustand store using `create<State & Actions>()(...)` pattern
   - Define strict TypeScript interfaces for State and Actions
   - Implement comprehensive error handling with try-catch blocks
   - Add structured logging for all state mutations
   - Include input validation for all action parameters using Zod schemas
   - Use immutable update patterns with proper type safety

3. **Add DevTools & Persistence Middleware:**
   - Include `devtools` middleware for Redux DevTools integration with custom action names
   - Include `persist` middleware for localStorage persistence
   - Add clear comment on future PostgreSQL migration path
   - Implement custom storage serialization if needed
   - Add version control for store migrations

4. **Error Handling & Validation:**
   - Wrap all mutations in try-catch blocks
   - Add validation schemas for all incoming state modifications
   - Implement proper error logging with context
   - Return meaningful error messages to consumers
   - Add recovery mechanisms for corrupted persisted state

5. **Testing Considerations:**
   - Ensure all actions are testable and have single responsibilities
   - Include inline documentation for complex logic
   - Provide examples of how to test the store with Jest
   - Add integration testing instructions

6. **Consider Existing Stores:** Mention how this new store might interact with existing stores (e.g., `filesStore`, `repositoryStore`, `authStore`) if relevant.

7. **Provide File Path:** Suggest a file path for the store (e.g., `src/lib/stores/new-store.ts`).

8. **Output:** Present the complete production-ready TypeScript code in a markdown code block with:
   - Strict mode compliance
   - Complete error handling
   - Structured logging integration
   - Zod validation schemas
   - Redux DevTools setup
   - Persistence configuration
   - Jest testing examples
   - Usage examples

Refer to the template `templates/zustand-store.ts` for the correct structure and always follow Airbnb TypeScript style guide.

---

**Output Template Structure:**
- Import statements (zod, zustand, middleware)
- Type definitions with strict TypeScript
- Zod validation schemas
- Store creation with middleware
- Error handling helpers
- Jest testing examples
- Usage examples
