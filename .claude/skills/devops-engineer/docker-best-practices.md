# Docker Best Practices for Production

Production Docker images require careful optimization for security, performance, and size. This guide covers proven patterns for containerizing applications safely and efficiently.

## Image Optimization

### Multi-Stage Builds

Multi-stage builds separate the build environment from the runtime, dramatically reducing final image size by excluding build tools and dependencies.

**Pattern:**

```dockerfile
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Runtime stage
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./
USER node
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD node healthcheck.js
CMD ["node", "dist/index.js"]
```

**Benefits:**
- Reduces final image size 50-70% (build tools excluded)
- Improves security (fewer dependencies in runtime)
- Faster image pulls and container startup
- Cleaner dependency management

### Layer Caching Strategy

Order Dockerfile commands from least-to-most frequently changing to maximize cache hits:

1. **Base image** (rarely changes)
2. **System dependencies** (rarely changes)
3. **Application dependencies** (sometimes changes)
4. **Application code** (frequently changes)

**Example:**

```dockerfile
FROM node:18-alpine

# Install system dependencies (cached until system needs change)
RUN apk add --no-cache curl dumb-init

# Copy and install app dependencies (cached until package.json changes)
COPY package*.json ./
RUN npm ci --production

# Copy application code (frequent changes, but benefits from cached layers above)
COPY . .

EXPOSE 3000
CMD ["dumb-init", "node", "dist/index.js"]
```

### Security Hardening

Never run containers as root. Implement minimal attack surface:

```dockerfile
FROM node:18-alpine

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

WORKDIR /app
COPY --chown=nodejs:nodejs . .
RUN npm ci --production

# Switch to non-root user
USER nodejs

EXPOSE 3000
CMD ["node", "dist/index.js"]
```

**Security Practices:**
- Run as non-root user (UID 1000+)
- Use read-only root filesystem when possible
- Drop unnecessary Linux capabilities: `--cap-drop=ALL`
- Avoid privileged mode (never use `--privileged`)
- Use secrets management (not ENV variables for secrets)

### Minimal Base Images

Choose base images carefully:

| Image | Size | Use Case |
|-------|------|----------|
| `alpine:3.19` | 7MB | System utilities, shell scripts |
| `node:18-alpine` | ~150MB | Node.js applications |
| `python:3.11-alpine` | ~150MB | Python applications |
| `golang:1.21-alpine` | ~380MB | Go applications |
| `ubuntu:24.04` | 80MB+ | When Alpine incompatible |

**Avoid:** Ubuntu, Debian, CentOS base images (>1GB) unless Alpine causes compatibility issues.

### Container Health Checks

Always include health checks for orchestrators to detect failing containers:

```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=40s \
  CMD curl -f http://localhost:3000/health || exit 1
```

**Explanation:**
- `--interval=30s`: Check every 30 seconds
- `--timeout=10s`: Fail if check takes >10s
- `--retries=3`: Mark unhealthy after 3 failures
- `--start-period=40s`: Wait for app startup

## Docker Compose Patterns

### Health Checks in Compose

```yaml
version: '3.9'
services:
  api:
    image: myapp:latest
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    ports:
      - "3000:3000"
```

### Resource Limits

Always set resource limits to prevent resource exhaustion:

```yaml
version: '3.9'
services:
  api:
    image: myapp:latest
    deploy:
      resources:
        limits:
          cpus: '0.5'        # Max 0.5 CPU core
          memory: 512M       # Max 512MB RAM
        reservations:
          cpus: '0.25'       # Guaranteed 0.25 CPU
          memory: 256M       # Guaranteed 256MB RAM
    ports:
      - "3000:3000"
```

### Environment Management

Never store secrets in images. Use compose secrets or environment files:

```yaml
version: '3.9'
services:
  api:
    image: myapp:latest
    environment:
      NODE_ENV: production
      LOG_LEVEL: info
    env_file:
      - .env.production  # NOT in git
    secrets:
      - db_password      # Compose secret
```

## Container Image Security

### Scanning with Trivy

Scan images for vulnerabilities before deployment:

```bash
# Scan local image
trivy image myapp:latest

# Scan with severity threshold
trivy image --severity HIGH,CRITICAL myapp:latest

# Generate JSON report
trivy image --format json --output report.json myapp:latest
```

### Scanning in CI/CD

```yaml
# GitHub Actions example
- name: Run Trivy scan
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: ${{ steps.meta.outputs.tags }}
    format: 'sarif'
    output: 'trivy-results.sarif'
```

### Private Registry Best Practices

- Use private registries (ECR, Docker Hub private, Harbor)
- Enable image signing (Notary, Sigstore)
- Scan all images before allowing deployment
- Enforce pull policies: `imagePullPolicy: Always` (Kubernetes)
- Use image digest references (immutable), not tags

## Performance Optimization

### Layer Size Reduction

```dockerfile
# ❌ Bad: Multiple RUNs create multiple layers
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get clean

# ✅ Good: Single RUN with cleanup
RUN apt-get update && \
    apt-get install -y curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

### Build Context Optimization

Use `.dockerignore` to exclude unnecessary files:

```dockerignore
.git
.gitignore
node_modules
npm-debug.log
dist
.env
.DS_Store
README.md
```

### Build Caching

Leverage Docker BuildKit for better caching:

```bash
# Enable BuildKit
export DOCKER_BUILDKIT=1

# Build with cache mount for package managers
docker build \
  --build-context=npm=/home/user/.npm \
  -t myapp:latest .
```

## Common Patterns

### Web Application (Node.js)

```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:18-alpine
RUN addgroup -g 1001 nodejs && adduser -S nodejs -u 1001
WORKDIR /app
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --chown=nodejs:nodejs package*.json ./
USER nodejs
EXPOSE 3000
HEALTHCHECK CMD curl -f http://localhost:3000/health || exit 1
CMD ["node", "dist/index.js"]
```

### Python Application

```dockerfile
FROM python:3.11-alpine AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

FROM python:3.11-alpine
RUN addgroup -g 1001 appuser && adduser -S appuser -u 1001
WORKDIR /app
COPY --from=builder --chown=appuser:appuser /root/.local /home/appuser/.local
COPY --chown=appuser:appuser . .
USER appuser
ENV PATH=/home/appuser/.local/bin:$PATH
EXPOSE 5000
HEALTHCHECK CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')"
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
```

### API Gateway

```dockerfile
FROM nginx:alpine
RUN addgroup -g 1001 nginx && \
    usermod -u 1001 nginx && \
    usermod -a -G 1001 nginx

COPY nginx.conf /etc/nginx/nginx.conf
RUN chown -R nginx:nginx /var/cache/nginx /var/log/nginx /var/run

USER nginx
EXPOSE 8080
HEALTHCHECK CMD wget --quiet --tries=1 --spider http://localhost:8080/health || exit 1
CMD ["nginx", "-g", "daemon off;"]
```

## Troubleshooting

### Image Size Issues

```bash
# Analyze image layers
docker history myapp:latest

# Find large files in build context
find . -type f -size +10M ! -path './.git/*' ! -path './node_modules/*'
```

### Permission Denied Errors

```bash
# Check file ownership in container
docker exec myapp ls -la /app

# Fix ownership in Dockerfile
COPY --chown=nodejs:nodejs . .
```

### Health Check Failures

```bash
# Test health check locally
docker run --rm myapp:latest curl http://localhost:3000/health

# Check health status
docker ps --filter "health=unhealthy"
```
