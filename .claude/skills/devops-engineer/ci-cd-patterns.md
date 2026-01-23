# CI/CD Pipeline Patterns

Production CI/CD pipelines must be fast, reliable, and enable confident deployments. This reference covers GitHub Actions patterns for building, testing, and deploying containerized applications.

## GitHub Actions Workflow Structure

### Complete Multi-Stage Pipeline

```yaml
name: Build, Test, and Deploy

on:
  push:
    branches:
      - main
      - develop
  pull_request:
    branches:
      - main
      - develop

env:
  REGISTRY: myregistry.azurecr.io
  IMAGE_NAME: myapp

jobs:
  test:
    name: Unit Tests
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18.x, 20.x]
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history for better caching

      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Lint code
        run: npm run lint

      - name: Run unit tests
        run: npm run test:unit

      - name: Run integration tests
        run: npm run test:integration
        env:
          DATABASE_URL: ${{ secrets.TEST_DATABASE_URL }}

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/coverage-final.json

  build:
    name: Build Container Image
    needs: test
    runs-on: ubuntu-latest
    if: github.event_name == 'push' || github.event.pull_request.draft == false
    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}
      image-digest: ${{ steps.build.outputs.digest }}
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Log in to registry
        if: github.event_name == 'push'
        uses: docker/login-action@v2
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ secrets.REGISTRY_USERNAME }}
          password: ${{ secrets.REGISTRY_PASSWORD }}

      - name: Generate image metadata
        id: meta
        uses: docker/metadata-action@v4
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha,prefix={{branch}}-
            type=raw,value=latest,enable={{is_default_branch}}

      - name: Build and push image
        id: build
        uses: docker/build-push-action@v4
        with:
          context: .
          push: ${{ github.event_name == 'push' }}
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
          build-args: |
            BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
            VCS_REF=${{ github.sha }}
            VERSION=${{ steps.meta.outputs.version }}

  scan:
    name: Security Scanning
    needs: build
    runs-on: ubuntu-latest
    if: github.event_name == 'push'
    steps:
      - name: Run Trivy scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ needs.build.outputs.image-tag }}
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'HIGH,CRITICAL'

      - name: Upload Trivy results to GitHub Security
        uses: github/codeql-action/upload-sarif@v2
        if: always()
        with:
          sarif_file: 'trivy-results.sarif'

  deploy-staging:
    name: Deploy to Staging
    needs: [build, scan]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    environment:
      name: staging
      url: https://staging.example.com
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to EKS (Staging)
        run: |
          aws eks update-kubeconfig --name staging-cluster --region us-east-1
          kubectl set image deployment/api api=${{ needs.build.outputs.image-tag }} -n default
          kubectl rollout status deployment/api -n default --timeout=5m
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

      - name: Smoke tests
        run: |
          npm install -g newman
          newman run ./postman/smoke-tests.json \
            --environment ./postman/staging.json \
            --reporters cli,json \
            --reporter-json-export ./test-results.json

  deploy-production:
    name: Deploy to Production
    needs: [build, scan]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    environment:
      name: production
      url: https://example.com
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to EKS (Production)
        run: |
          aws eks update-kubeconfig --name prod-cluster --region us-east-1
          kubectl set image deployment/api api=${{ needs.build.outputs.image-tag }} -n default
          kubectl rollout status deployment/api -n default --timeout=10m
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

      - name: Verify deployment
        run: |
          kubectl get deployment api -n default
          kubectl get service api -n default
          curl -f https://example.com/health || exit 1

      - name: Slack notification
        if: always()
        uses: slackapi/slack-github-action@v1
        with:
          webhook-url: ${{ secrets.SLACK_WEBHOOK }}
          payload: |
            {
              "text": "Deployment to Production: ${{ job.status }}",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "*Deployment to Production*\nStatus: ${{ job.status }}\nVersion: ${{ needs.build.outputs.image-tag }}"
                  }
                }
              ]
            }
```

## Caching Strategies

### Docker Layer Caching

```yaml
- name: Set up Docker Buildx
  uses: docker/setup-buildx-action@v2

- name: Build with cache
  uses: docker/build-push-action@v4
  with:
    context: .
    cache-from: type=gha              # Read cache from GitHub Actions
    cache-to: type=gha,mode=max       # Store all layers in cache
    tags: ${{ steps.meta.outputs.tags }}
```

### Dependency Caching

```yaml
- uses: actions/setup-node@v4
  with:
    node-version: '18'
    cache: 'npm'                # Caches package-lock.json

- uses: actions/setup-python@v4
  with:
    python-version: '3.11'
    cache: 'pip'                # Caches pip dependencies
```

## Secret Management

### GitHub Secrets

```yaml
env:
  DATABASE_URL: ${{ secrets.DATABASE_URL }}
  API_KEY: ${{ secrets.API_KEY }}

jobs:
  deploy:
    steps:
      - name: Deploy
        run: |
          # Secrets are automatically masked in logs
          echo "Deploying with API key: ${API_KEY:0:4}****"
```

### Vault Integration

```yaml
- name: Retrieve secrets from HashiCorp Vault
  uses: hashicorp/vault-action@v2
  with:
    url: https://vault.example.com
    method: jwt
    role: github-actions
    jwtPayload: ${{ secrets.VAULT_JWT }}
    secrets: |
      secret/data/prod/db db_password |
      secret/data/prod/api api_key |
```

## Deployment Strategies

### Rolling Deployment

```yaml
deploy:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
```

```yaml
- name: Rolling deploy
  run: |
    kubectl set image deployment/api api=$IMAGE_TAG
    kubectl rollout status deployment/api --timeout=10m
```

### Blue-Green Deployment

```yaml
- name: Deploy to green environment
  run: |
    kubectl create deployment api-green --image=$IMAGE_TAG
    kubectl service api-green --port=80 --target-port=3000

- name: Switch traffic to green
  run: |
    kubectl patch service api -p '{"spec":{"selector":{"version":"green"}}}'

- name: Remove old blue deployment
  run: |
    kubectl delete deployment api-blue
```

### Canary Deployment with Flagger

```yaml
apiVersion: flagger.app/v1beta1
kind: Canary
metadata:
  name: api
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api
  progressDeadlineSeconds: 300
  service:
    port: 80
    targetPort: 3000
  analysis:
    interval: 1m
    threshold: 5
    maxWeight: 50
    stepWeight: 10
    metrics:
    - name: request-success-rate
      thresholdRange:
        min: 99
      interval: 1m
    - name: request-duration
      thresholdRange:
        max: 500
      interval: 1m
  skipAnalysis: false
  stages:
  - name: staging
    match:
    - uri:
        prefix: /staging
```

## Manual Approval Gates

```yaml
deploy-production:
  environment:
    name: production
    url: https://example.com
  runs-on: ubuntu-latest
  needs: deploy-staging
  steps:
    # Manual approval required before this job starts
    - name: Deploy to production
      run: |
        kubectl set image deployment/api api=$IMAGE_TAG
```

## Rollback Procedures

### Automatic Rollback on Failure

```yaml
- name: Deploy and rollback on failure
  run: |
    CURRENT_IMAGE=$(kubectl get deployment api -o jsonpath='{.spec.template.spec.containers[0].image}')
    kubectl set image deployment/api api=$NEW_IMAGE
    
    # Wait for rollout
    if ! kubectl rollout status deployment/api --timeout=5m; then
      echo "Deployment failed, rolling back..."
      kubectl set image deployment/api api=$CURRENT_IMAGE
      kubectl rollout status deployment/api
      exit 1
    fi
```

### Manual Rollback

```bash
# Check rollout history
kubectl rollout history deployment/api

# Rollback to previous version
kubectl rollout undo deployment/api

# Rollback to specific revision
kubectl rollout undo deployment/api --to-revision=3
```

## Monitoring Pipeline Performance

### Job Timing

```yaml
- name: Report job duration
  if: always()
  run: |
    DURATION=$((SECONDS / 60))
    echo "Job took $DURATION minutes"
    # Send to monitoring system
    curl -X POST https://monitoring.example.com/metrics \
      -d "pipeline_duration_minutes=$DURATION"
```

## Common Patterns

### Feature Branch Testing

Only run full test suite on pull requests, skip build/deploy:

```yaml
on:
  pull_request:
    branches:
      - main

jobs:
  test:
    # Tests run for all PRs
  build:
    if: ${{ false }}  # Skip for PRs
```

### Scheduled Security Scanning

```yaml
on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly on Sunday

jobs:
  security-scan:
    runs-on: ubuntu-latest
```

### Conditional Build Based on Changed Files

```yaml
- name: Check for code changes
  id: changes
  uses: dorny/paths-filter@v2
  with:
    filters: |
      api:
        - 'src/**'
        - 'package.json'

- name: Build API
  if: steps.changes.outputs.api == 'true'
  run: npm run build
```
