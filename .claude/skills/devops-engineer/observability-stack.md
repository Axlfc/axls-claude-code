# Observability Stack Configuration

Production infrastructure requires comprehensive monitoring, logging, and alerting. This guide covers setting up Prometheus, Grafana, and Loki for complete observability.

## Prometheus Setup

### Prometheus ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
      external_labels:
        cluster: 'production'
        environment: 'prod'

    alerting:
      alertmanagers:
      - static_configs:
        - targets:
          - alertmanager:9093

    rule_files:
      - '/etc/prometheus/rules/*.yml'

    scrape_configs:
    - job_name: 'prometheus'
      static_configs:
      - targets: ['localhost:9090']

    - job_name: 'kubernetes-pods'
      kubernetes_sd_configs:
      - role: pod
      relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
      - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
        action: replace
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2
        target_label: __address__

    - job_name: 'kubernetes-nodes'
      kubernetes_sd_configs:
      - role: node
      scheme: https
      tls_config:
        ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
      bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
```

### Prometheus Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: monitoring
spec:
  replicas: 2
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      serviceAccountName: prometheus
      containers:
      - name: prometheus
        image: prom/prometheus:v2.45.0
        args:
          - '--config.file=/etc/prometheus/prometheus.yml'
          - '--storage.tsdb.path=/prometheus'
          - '--storage.tsdb.retention.time=15d'
          - '--web.console.libraries=/usr/share/prometheus/console_libraries'
          - '--web.console.templates=/usr/share/prometheus/consoles'
        ports:
        - containerPort: 9090
        resources:
          requests:
            cpu: 500m
            memory: 2Gi
          limits:
            cpu: 1000m
            memory: 4Gi
        volumeMounts:
        - name: config
          mountPath: /etc/prometheus
        - name: rules
          mountPath: /etc/prometheus/rules
        - name: storage
          mountPath: /prometheus
        livenessProbe:
          httpGet:
            path: /-/healthy
            port: 9090
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /-/ready
            port: 9090
          initialDelaySeconds: 10
          periodSeconds: 5
      volumes:
      - name: config
        configMap:
          name: prometheus-config
      - name: rules
        configMap:
          name: prometheus-rules
      - name: storage
        persistentVolumeClaim:
          claimName: prometheus-storage
```

### Alert Rules

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-rules
  namespace: monitoring
data:
  alert-rules.yml: |
    groups:
    - name: application
      interval: 30s
      rules:
      - alert: HighErrorRate
        expr: rate(http_request_duration_seconds_bucket{le="+Inf"}[5m]) - rate(http_requests_total{status=~"5.."}[5m]) < 0.95
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High error rate detected"
          description: "Error rate > 5% for 5 minutes"

      - alert: HighLatency
        expr: histogram_quantile(0.95, http_request_duration_seconds) > 1.0
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High request latency"
          description: "P95 latency > 1 second"

      - alert: PodCrashLooping
        expr: rate(kube_pod_container_status_restarts_total[1h]) > 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Pod crash looping"
          description: "Pod {{ $labels.pod }} restarting more than once per hour"

      - alert: HighMemoryUsage
        expr: |
          (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) > 0.85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage"
          description: "Memory usage > 85% on node {{ $labels.node }}"

      - alert: DiskSpaceLow
        expr: |
          (node_filesystem_avail_bytes{fstype!~"tmpfs|fuse.lxcfs|squashfs|vfat"} / 
           node_filesystem_size_bytes) < 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Disk space running low"
          description: "Less than 10% disk space available on {{ $labels.device }}"

      - alert: DatabaseConnectionPoolExhausted
        expr: pg_stat_activity_count > 90
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Database connection pool near limit"
          description: "{{ $value }} connections out of 100 max"
```

## Grafana Setup

### Grafana Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: monitoring
spec:
  replicas: 2
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:10.0.0
        ports:
        - containerPort: 3000
        env:
        - name: GF_SECURITY_ADMIN_PASSWORD
          valueFrom:
            secretKeyRef:
              name: grafana-admin
              key: password
        - name: GF_SECURITY_ADMIN_USER
          value: admin
        - name: GF_INSTALL_PLUGINS
          value: grafana-piechart-panel
        - name: GF_AUTH_ANONYMOUS_ENABLED
          value: "false"
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
        volumeMounts:
        - name: storage
          mountPath: /var/lib/grafana
        - name: provisioning
          mountPath: /etc/grafana/provisioning
      volumes:
      - name: storage
        persistentVolumeClaim:
          claimName: grafana-storage
      - name: provisioning
        configMap:
          name: grafana-provisioning
```

### Grafana Dashboard Provisioning

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-provisioning
  namespace: monitoring
data:
  datasources.yml: |
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      access: proxy
      url: http://prometheus:9090
      isDefault: true
      editable: true
    - name: Loki
      type: loki
      access: proxy
      url: http://loki:3100
      editable: true

  dashboards.yml: |
    apiVersion: 1
    providers:
    - name: 'default'
      orgId: 1
      folder: ''
      type: file
      disableDeletion: false
      editable: true
      options:
        path: /var/lib/grafana/dashboards

  dashboards.json: |
    {
      "dashboard": {
        "title": "Application Metrics",
        "panels": [
          {
            "title": "Request Rate",
            "targets": [
              {
                "expr": "rate(http_requests_total[5m])"
              }
            ]
          },
          {
            "title": "Error Rate",
            "targets": [
              {
                "expr": "rate(http_requests_total{status=~\"5..\"}[5m])"
              }
            ]
          },
          {
            "title": "P95 Latency",
            "targets": [
              {
                "expr": "histogram_quantile(0.95, http_request_duration_seconds)"
              }
            ]
          },
          {
            "title": "Active Connections",
            "targets": [
              {
                "expr": "pg_stat_activity_count"
              }
            ]
          }
        ]
      }
    }
```

## Loki Setup (Log Aggregation)

### Loki Deployment

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: loki-config
  namespace: monitoring
data:
  loki-config.yaml: |
    auth_enabled: false
    ingester:
      chunk_idle_period: 3m
      chunk_retain_period: 1m
    limits_config:
      enforce_metric_name: false
      reject_old_samples: true
      reject_old_samples_max_age: 168h
    schema_config:
      configs:
      - from: 2020-10-24
        store: boltdb-shipper
        object_store: filesystem
        schema: v11
        index:
          prefix: index_
          period: 24h
    server:
      http_listen_port: 3100
    storage_config:
      boltdb_shipper:
        active_index_directory: /loki/boltdb-shipper-active
        shared_store: filesystem
      filesystem:
        directory: /loki/chunks
    chunk_store_config:
      max_look_back_period: 0s
    table_manager:
      retention_deletes_enabled: false
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: loki
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: loki
  template:
    metadata:
      labels:
        app: loki
    spec:
      containers:
      - name: loki
        image: grafana/loki:2.9.0
        ports:
        - containerPort: 3100
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
        volumeMounts:
        - name: loki-config
          mountPath: /etc/loki
        - name: loki-storage
          mountPath: /loki
      volumes:
      - name: loki-config
        configMap:
          name: loki-config
      - name: loki-storage
        persistentVolumeClaim:
          claimName: loki-storage
```

## Promtail Setup (Log Shipper)

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: promtail-config
  namespace: monitoring
data:
  promtail-config.yaml: |
    clients:
    - url: http://loki:3100/loki/api/v1/push
    positions:
      filename: /tmp/positions.yaml
    scrape_configs:
    - job_name: kubernetes-pods
      kubernetes_sd_configs:
      - role: pod
      relabel_configs:
      - source_labels: [__meta_kubernetes_pod_name]
        action: replace
        target_label: pod
      - source_labels: [__meta_kubernetes_namespace]
        action: replace
        target_label: namespace
      - source_labels: [__meta_kubernetes_pod_label_app]
        action: replace
        target_label: app
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: promtail
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: promtail
  template:
    metadata:
      labels:
        app: promtail
    spec:
      containers:
      - name: promtail
        image: grafana/promtail:2.9.0
        args:
          - -config.file=/etc/promtail/promtail-config.yaml
          - -client.url=http://loki:3100/loki/api/v1/push
        volumeMounts:
        - name: config
          mountPath: /etc/promtail
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
      volumes:
      - name: config
        configMap:
          name: promtail-config
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
```

## Alertmanager Configuration

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: alertmanager-config
  namespace: monitoring
data:
  alertmanager.yml: |
    global:
      resolve_timeout: 5m
    route:
      receiver: 'default'
      group_by: ['alertname', 'cluster', 'service']
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 12h
      routes:
      - match:
          severity: critical
        receiver: 'pagerduty'
        continue: true
      - match:
          severity: warning
        receiver: 'slack'
    receivers:
    - name: 'default'
      slack_configs:
      - api_url: $SLACK_WEBHOOK_URL
        channel: '#alerts'
        title: '{{ .GroupLabels.alertname }}'
        text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'
    - name: 'pagerduty'
      pagerduty_configs:
      - service_key: $PAGERDUTY_SERVICE_KEY
        description: '{{ .GroupLabels.alertname }}'
```

## Key Metrics to Monitor

### Application Metrics
- Request rate (requests/second)
- Error rate (errors/requests)
- Latency (p50, p95, p99)
- Active connections
- Queue depth

### Infrastructure Metrics
- CPU usage per node
- Memory usage per node
- Disk space available
- Network I/O
- Pod restart count

### Database Metrics
- Query execution time
- Connection pool usage
- Replication lag
- Transaction throughput
- Lock contention

### Business Metrics
- User sessions
- API endpoint usage
- Feature adoption
- Revenue impact
