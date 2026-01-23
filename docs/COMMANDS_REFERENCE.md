# Commands Reference

Complete reference for all 10 slash commands in axls-claude-code.

## Development Commands

### `/api-endpoint`
**Description:** Generate production-ready Fastify REST API endpoint

**Usage:**
```
/api-endpoint
```
Then describe the endpoint you need.

**Generates:**
- TypeScript route file with Zod validation
- Proper error handling
- Request/response types
- Example usage comments

**Example:**
```
User: /api-endpoint
Create a POST /users endpoint that accepts name and email
```

---

### `/component-new`
**Description:** Create React component with shadcn/ui and Tailwind

**Usage:**
```
/component-new
```

**Generates:**
- TypeScript React component
- Props interface
- Tailwind CSS styling
- Accessibility considerations

**Best For:** UI components, forms, layouts

---

### `/lint-fix`
**Description:** Format and lint code files

**Usage:**
```
/lint-fix
```

**Supports:**
- TypeScript/JavaScript (Prettier + ESLint)
- Python (Ruff)
- Auto-fixes common issues

---

### `/test-gen`
**Description:** Generate test file for existing code

**Usage:**
```
/test-gen
```

**Generates:**
- Jest/Vitest test file
- Test cases for main functionality
- Mocks for dependencies
- Coverage-friendly structure

---

## Infrastructure Commands

### `/docker-service`
**Description:** Docker Compose service configuration

**Usage:**
```
/docker-service
```

**Generates:**
- docker-compose.yml snippet
- Environment variables
- Volume mappings
- Health checks
- Resource limits

---

### `/k8s-manifest`
**Description:** Kubernetes Deployment, Service, and Ingress

**Usage:**
```
/k8s-manifest
```

**Generates:**
- Deployment with resource limits
- Service (ClusterIP/LoadBalancer)
- Ingress (optional)
- Health probes
- Security context

---

### `/db-migration`
**Description:** PostgreSQL migration file

**Usage:**
```
/db-migration
```

**Generates:**
- SQL migration with transactions
- `up` and `down` sections
- Proper indexes
- Foreign key constraints

---

## Integration Commands

### `/new-workflow`
**Description:** n8n workflow JSON structure

**Usage:**
```
/new-workflow
```

**Generates:**
- Complete n8n workflow JSON
- Nodes configuration
- Connections
- Error handling

---

### `/sentry-integration`
**Description:** Sentry error tracking setup

**Usage:**
```
/sentry-integration
```

**Generates:**
- Sentry initialization code
- Error boundary (React)
- Performance monitoring
- Environment configuration

---

### `/store-new`
**Description:** Zustand store with TypeScript

**Usage:**
```
/store-new
```

**Generates:**
- TypeScript store file
- State interface
- Actions with error handling
- DevTools integration
- Test stub

---

## Tips

- All commands generate production-ready code
- TypeScript strict mode enforced
- Error handling included by default
- Tests generated when appropriate
- Security best practices followed

## Customization

Want to modify command behavior? Edit files in `.claude/commands/`

## Related

- See [SKILLS_REFERENCE.md](./SKILLS_REFERENCE.md) for skills
- See [AGENTS_REFERENCE.md](./AGENTS_REFERENCE.md) for agents
