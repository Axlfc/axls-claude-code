# Kubernetes Architecture Reference

Production Kubernetes (EKS) deployments require careful consideration of reliability, security, and operational concerns. This reference provides essential patterns and manifest templates.

## Deployment Patterns

### Basic Deployment with Health Checks

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: default
  labels:
    app: api
    version: v1
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "9090"
        prometheus.io/path: "/metrics"
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - api
              topologyKey: kubernetes.io/hostname
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 1000
      containers:
      - name: api
        image: myregistry.azurecr.io/api:v1.2.3
        imagePullPolicy: IfNotPresent
        ports:
        - name: http
          containerPort: 3000
          protocol: TCP
        - name: metrics
          containerPort: 9090
          protocol: TCP
        env:
        - name: NODE_ENV
          value: production
        - name: LOG_LEVEL
          value: info
        - name: DB_HOST
          valueFrom:
            secretKeyRef:
              name: database
              key: host
        resources:
          requests:
            cpu: 250m
            memory: 256Mi
          limits:
            cpu: 500m
            memory: 512Mi
        livenessProbe:
          httpGet:
            path: /health/live
            port: http
            httpHeaders:
            - name: X-Probe
              value: liveness
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /health/ready
            port: http
            httpHeaders:
            - name: X-Probe
              value: readiness
          initialDelaySeconds: 10
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 2
        startupProbe:
          httpGet:
            path: /health/startup
            port: http
          failureThreshold: 30
          periodSeconds: 10
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          capabilities:
            drop:
            - ALL
        volumeMounts:
        - name: tmp
          mountPath: /tmp
        - name: cache
          mountPath: /app/cache
      volumes:
      - name: tmp
        emptyDir: {}
      - name: cache
        emptyDir: {}
      terminationGracePeriodSeconds: 30
```

### Service Definition

```yaml
apiVersion: v1
kind: Service
metadata:
  name: api
  namespace: default
  labels:
    app: api
spec:
  type: ClusterIP
  selector:
    app: api
  ports:
  - name: http
    port: 80
    targetPort: http
    protocol: TCP
  sessionAffinity: None
```

### Ingress Configuration

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api
  namespace: default
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/rate-limit: "100"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - api.example.com
    secretName: api-tls
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api
            port:
              name: http
```

## Network Policies

### Deny All by Default

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

### Allow Specific Traffic

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-api-to-db
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: postgresql
    ports:
    - protocol: TCP
      port: 5432
```

## Pod Disruption Budget

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: api
  namespace: default
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: api
```

## ConfigMap and Secret Management

### ConfigMap for Configuration

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: api-config
  namespace: default
data:
  app.yaml: |
    server:
      port: 3000
      timeout: 30s
    logging:
      level: info
      format: json
```

### Secret for Sensitive Data

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: api-secrets
  namespace: default
type: Opaque
stringData:
  db_password: "secretpassword"
  api_key: "secretkey"
```

## StatefulSet for Stateful Services

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
  namespace: default
spec:
  serviceName: postgres
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15-alpine
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_DB
          value: myapp
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: password
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
        livenessProbe:
          exec:
            command:
            - /bin/sh
            - -c
            - pg_isready -U postgres
          initialDelaySeconds: 30
          periodSeconds: 10
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
```

## Resource Quotas

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: default-quota
  namespace: default
spec:
  hard:
    requests.cpu: "10"
    requests.memory: 20Gi
    limits.cpu: "20"
    limits.memory: 40Gi
    pods: "100"
```

## Monitoring ServiceMonitor (Prometheus)

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: api
  namespace: default
  labels:
    app: api
spec:
  selector:
    matchLabels:
      app: api
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
```

## Common Issues and Solutions

### Resource Constraints

**Issue:** Pods not scheduling due to insufficient resources

**Solution:**
```bash
# Check node resources
kubectl top nodes

# Describe node for detailed info
kubectl describe node node-name

# Check resource limits on pod
kubectl top pod pod-name --containers
```

### Health Check Failures

**Issue:** Pods stuck in CrashLoopBackOff

**Solution:**
```bash
# Check logs
kubectl logs pod-name

# Check events
kubectl describe pod pod-name

# Adjust initialDelaySeconds or periodSeconds in probes
```

### Image Pull Errors

**Issue:** ImagePullBackOff errors

**Solution:**
```yaml
imagePullSecrets:
- name: regcred

# Create secret for private registry
kubectl create secret docker-registry regcred \
  --docker-server=myregistry.azurecr.io \
  --docker-username=username \
  --docker-password=password
```

## Best Practices Summary

1. **Always set resource requests and limits** - Enables proper scheduling and prevents resource exhaustion
2. **Implement all three probes** - Startup, liveness, and readiness probes for reliability
3. **Use rolling updates with proper surge/unavailable settings** - Ensures zero-downtime deployments
4. **Implement pod anti-affinity** - Distributes pods across nodes for high availability
5. **Use network policies** - Restrict traffic to what's necessary
6. **Configure pod disruption budgets** - Protects critical workloads during cluster maintenance
7. **Use proper security contexts** - Non-root users, read-only filesystems
8. **Monitor everything** - Prometheus metrics, logs, and health checks
