# Tarragona Connect (TC) Stores Reference

Documentation of all 22 Zustand stores used in Tarragona Connect with their responsibilities, state structure, and interdependencies.

## Core Stores (4)

### 1. authStore
**Responsibility:** Authentication and session management
**Key State:**
- `user: User | null` - Current user
- `session: Session | null` - Session info
- `isAuthenticated: boolean`
- `loginError: string | null`

**Key Actions:**
- `login(email, password)`
- `logout()`
- `refreshSession()`
- `setUser(user)`

**Dependencies:** None (root store)
**Dependents:** userSettingsStore, activityStore

---

### 2. userSettingsStore
**Responsibility:** User preferences and configuration
**Key State:**
- `theme: 'light' | 'dark'`
- `language: string`
- `notificationPreferences: NotificationSettings`
- `displayPreferences: DisplaySettings`

**Key Actions:**
- `setTheme(theme)`
- `setLanguage(lang)`
- `updateNotificationPreferences(prefs)`
- `loadSettings(userId)`

**Dependencies:** authStore
**Dependents:** uiStore

---

### 3. appStore
**Responsibility:** Global app UI state
**Key State:**
- `isLoading: boolean`
- `errorMessage: string | null`
- `sidebarOpen: boolean`
- `modalStack: Modal[]`
- `toast: Toast | null`

**Key Actions:**
- `setLoading(loading)`
- `setError(message)`
- `toggleSidebar()`
- `openModal(modal)`
- `closeModal()`
- `showToast(toast)`

**Dependencies:** None
**Dependents:** All UI components

---

### 4. notificationStore
**Responsibility:** In-app notifications and real-time updates
**Key State:**
- `notifications: Record<string, Notification>`
- `unreadCount: number`
- `websocketConnected: boolean`

**Key Actions:**
- `addNotification(notification)`
- `markAsRead(id)`
- `clearNotification(id)`
- `connectWebSocket()`
- `disconnectWebSocket()`

**Dependencies:** authStore, appStore
**Dependents:** activityStore

---

## File & Project Management (5)

### 5. filesStore
**Responsibility:** Document and file management
**Key State:**
- `files: Record<string, File>` (normalized)
- `selectedFileId: string | null`
- `fileTree: FileTreeNode[]`
- `uploads: Record<string, UploadProgress>`

**Key Actions:**
- `loadFiles(projectId)`
- `createFile(name, projectId)`
- `updateFile(id, updates)`
- `deleteFile(id)`
- `selectFile(id)`
- `uploadFile(file)`

**Dependencies:** authStore, projectStore
**Dependents:** editorStore, previewStore

---

### 6. projectStore
**Responsibility:** Project management and metadata
**Key State:**
- `projects: Record<string, Project>`
- `selectedProjectId: string | null`
- `projectSettings: ProjectSettings`
- `collaborators: Record<string, Collaborator>`

**Key Actions:**
- `loadProjects()`
- `createProject(name, description)`
- `updateProject(id, updates)`
- `deleteProject(id)`
- `selectProject(id)`
- `addCollaborator(userId)`
- `removeCollaborator(userId)`

**Dependencies:** authStore
**Dependents:** filesStore, workflowStore, shareStore

---

### 7. editorStore
**Responsibility:** Text editor state and content
**Key State:**
- `content: string`
- `cursorPosition: number`
- `selection: Selection | null`
- `isDirty: boolean`
- `history: EditorHistory`

**Key Actions:**
- `updateContent(content)`
- `setCursorPosition(pos)`
- `setSelection(selection)`
- `undo()`
- `redo()`
- `save()`

**Dependencies:** filesStore
**Dependents:** previewStore, syntaxStore

---

### 8. previewStore
**Responsibility:** Preview/rendering state
**Key State:**
- `rendered: RenderedContent`
- `renderError: string | null`
- `isRendering: boolean`
- `theme: 'light' | 'dark'`

**Key Actions:**
- `render(content, type)`
- `setTheme(theme)`
- `syncWithEditor()`

**Dependencies:** editorStore, userSettingsStore
**Dependents:** None

---

### 9. shareStore
**Responsibility:** Sharing and collaboration
**Key State:**
- `sharedItems: Record<string, SharedItem>`
- `shareLinks: Record<string, ShareLink>`
- `accessRequests: AccessRequest[]`

**Key Actions:**
- `shareWith(itemId, userId, permissions)`
- `createShareLink(itemId)`
- `revokeAccess(itemId, userId)`
- `respondToAccessRequest(requestId, approved)`

**Dependencies:** projectStore, filesStore, authStore
**Dependents:** None

---

## Workflow & Automation (3)

### 10. workflowStore
**Responsibility:** Workflow definitions and execution
**Key State:**
- `workflows: Record<string, Workflow>`
- `selectedWorkflowId: string | null`
- `executions: Record<string, Execution>`
- `triggers: Record<string, Trigger[]>`

**Key Actions:**
- `loadWorkflows(projectId)`
- `createWorkflow(definition)`
- `updateWorkflow(id, definition)`
- `executeWorkflow(id)`
- `addTrigger(workflowId, trigger)`
- `removeTrigger(workflowId, triggerId)`

**Dependencies:** projectStore
**Dependents:** schedulerStore, notificationStore

---

### 11. schedulerStore
**Responsibility:** Scheduled tasks and cron jobs
**Key State:**
- `scheduledTasks: Record<string, ScheduledTask>`
- `nextRun: Record<string, Date>`
- `logs: SchedulerLog[]`

**Key Actions:**
- `scheduleTask(task)`
- `updateSchedule(taskId, cron)`
- `removeSchedule(taskId)`
- `pauseTask(taskId)`
- `resumeTask(taskId)`

**Dependencies:** workflowStore
**Dependents:** None

---

### 12. integrationStore
**Responsibility:** Third-party integrations and API connections
**Key State:**
- `integrations: Record<string, Integration>`
- `credentials: Record<string, Credential>`
- `oauth2States: Record<string, OAuth2State>`

**Key Actions:**
- `connectIntegration(type, config)`
- `disconnectIntegration(id)`
- `updateCredentials(id, creds)`
- `testConnection(id)`

**Dependencies:** authStore, projectStore
**Dependents:** workflowStore

---

## Search & Discovery (2)

### 13. searchStore
**Responsibility:** Full-text search and filtering
**Key State:**
- `query: string`
- `results: SearchResult[]`
- `filters: SearchFilter[]`
- `isSearching: boolean`

**Key Actions:**
- `setQuery(query)`
- `search(query, filters)`
- `addFilter(filter)`
- `removeFilter(filterId)`
- `clearSearch()`

**Dependencies:** filesStore, projectStore
**Dependents:** None

---

### 14. filterStore
**Responsibility:** Advanced filtering and saved filters
**Key State:**
- `filters: Record<string, SavedFilter>`
- `activeFilterId: string | null`
- `filterHistory: string[]`

**Key Actions:**
- `createFilter(name, conditions)`
- `updateFilter(id, conditions)`
- `deleteFilter(id)`
- `applyFilter(filterId)`
- `saveFilterAsPreset(name)`

**Dependencies:** searchStore
**Dependents:** None

---

## Collaboration & Communication (3)

### 15. commentStore
**Responsibility:** Comments and discussions
**Key State:**
- `comments: Record<string, Comment>`
- `commentThreads: Record<string, Thread>`
- `selectedThreadId: string | null`
- `unreadComments: Set<string>`

**Key Actions:**
- `loadComments(fileId)`
- `addComment(content, fileId, position)`
- `replyToComment(parentId, content)`
- `resolveThread(threadId)`
- `markAsRead(commentId)`

**Dependencies:** filesStore, authStore
**Dependents:** None

---

### 16. activityStore
**Responsibility:** User activity and presence
**Key State:**
- `activeUsers: Record<string, UserActivity>`
- `userEdits: Record<string, EditActivity[]>`
- `presence: Record<string, PresenceInfo>`

**Key Actions:**
- `reportActivity(type, data)`
- `setPresence(status)`
- `trackEdit(fileId, changes)`
- `broadcastCursorPosition(fileId, pos)`

**Dependencies:** authStore, notificationStore
**Dependents:** None

---

### 17. cacheStore
**Responsibility:** Application-level caching
**Key State:**
- `cache: Record<string, CacheEntry>`
- `metadata: Record<string, CacheMeta>`

**Key Actions:**
- `set(key, value, ttl)`
- `get(key)`
- `delete(key)`
- `clear()`
- `prefetch(key, fetcher)`

**Dependencies:** None
**Dependents:** All stores (utility)

---

## UI & Configuration (4)

### 18. uiStore
**Responsibility:** UI layout and component state
**Key State:**
- `layout: Layout`
- `panelState: Record<string, PanelState>`
- `viewMode: 'split' | 'single' | 'preview'`
- `zoomLevel: number`

**Key Actions:**
- `setLayout(layout)`
- `togglePanel(panelId)`
- `setViewMode(mode)`
- `setZoomLevel(level)`

**Dependencies:** userSettingsStore, appStore
**Dependents:** None

---

### 19. syntaxStore
**Responsibility:** Syntax highlighting and language config
**Key State:**
- `language: string`
- `theme: 'light' | 'dark'`
- `customTheme: CustomTheme | null`

**Key Actions:**
- `setLanguage(lang)`
- `setTheme(theme)`
- `loadCustomTheme(theme)`

**Dependencies:** userSettingsStore
**Dependents:** editorStore, previewStore

---

### 20. featureFlagsStore
**Responsibility:** Feature flags and A/B testing
**Key State:**
- `flags: Record<string, boolean>`
- `experiments: Record<string, Experiment>`

**Key Actions:**
- `loadFlags(userId)`
- `isEnabled(flagName)`
- `getVariant(experimentName)`

**Dependencies:** authStore
**Dependents:** All stores (conditional features)

---

### 21. analyticsStore
**Responsibility:** Analytics and metrics
**Key State:**
- `events: AnalyticsEvent[]`
- `sessionStart: Date`
- `pageViewCount: number`

**Key Actions:**
- `trackEvent(event)`
- `trackPageView(path)`
- `trackError(error)`
- `endSession()`

**Dependencies:** authStore, appStore
**Dependents:** None

---

## Utilities (1)

### 22. recentStore
**Responsibility:** Recently accessed items and history
**Key State:**
- `recentItems: RecentItem[]`
- `recentProjects: Project[]`
- `recentSearches: string[]`

**Key Actions:**
- `addToRecent(item)`
- `clearRecent()`
- `removeFromRecent(itemId)`
- `getRecentProjects(limit)`

**Dependencies:** filesStore, projectStore
**Dependents:** None

---

## Store Dependency Graph

```
authStore (root)
├── userSettingsStore
│   └── uiStore
├── projectStore
│   ├── filesStore
│   │   ├── editorStore
│   │   │   └── previewStore
│   │   └── commentStore
│   ├── workflowStore
│   │   └── schedulerStore
│   └── shareStore
├── notificationStore
│   └── activityStore
└── analyticsStore

integrationStore
└── workflowStore

searchStore → filterStore

Utility Stores:
- cacheStore (used by all)
- featureFlagsStore (used by all for conditional features)
- syntaxStore (used by editorStore, previewStore)
- recentStore (used by many for history)
```

## Inter-Store Communication Patterns

### Direct Dependency
```typescript
// When one store needs another's state
const userSettings = useUserSettingsStore((s) => s.theme);
const files = useFilesStore((s) => s.files);
```

### State Synchronization
```typescript
// Sync between related stores when updated
useProjectStore.subscribe(
  (state) => state.selectedProjectId,
  (projectId) => {
    useFilesStore.getState().loadFiles(projectId);
  }
);
```

### Event Publishing
```typescript
// Use notificationStore or appStore for cross-store events
useAppStore.getState().showToast({
  type: 'success',
  message: 'File saved',
});
```

## Persistence Configuration

**Persisted to localStorage:**
- userSettingsStore (theme, language, preferences)
- recentStore (recent items)
- uiStore (layout preferences)
- searchStore (search history)

**Persisted to PostgreSQL (post-migration):**
- All user-generated content (files, projects, workflows)
- Comments, activities, shares
- User-specific configuration

**Not Persisted:**
- authStore (session in memory/cookie)
- appStore (transient UI state)
- editorStore (drafts only, synced to files)
- notificationStore (transient messages)
- cacheStore (runtime cache only)
