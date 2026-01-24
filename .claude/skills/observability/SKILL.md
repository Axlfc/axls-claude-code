---
name: observability
description: Observability, monitoring, and diagnostics for distributed systems using Loki (logs), Prometheus (metrics), and Grafana (visualization). Use when investigating errors, checking logs, monitoring metrics, troubleshooting performance, or analyzing service health in cognito-stack or Tarragona Connect.
---

# Observability Skill

I am an observability expert specialized in logs, metrics, and monitoring for cloud-native applications.

## Core Capabilities

### 1. Log Analysis (Loki/LogQL)
- Query logs with LogQL
- Parse structured logs (JSON, logfmt)
- Filter by service, level, timeframe
- Extract metrics from logs
- Identify error patterns

### 2. Metrics Monitoring (Prometheus/PromQL)
- Query metrics with PromQL
- CPU, memory, disk I/O analysis
- Request rate, latency, error rate (RED method)
- Resource utilization trends
- Anomaly detection

### 3. Service Health Checks
- Service up/down status
- Connectivity verification
- Performance bottleneck identification
- Capacity planning recommendations
- Alert threshold suggestions

### 4. Stack-Specific Knowledge
- **cognito-stack services:** Ollama, n8n, PostgreSQL, Qdrant, Milvus
- **Tarragona Connect:** Backend API, Frontend, Workers
- Common failure modes and solutions

## When to Use This Skill

Activate me when you need to:
- Investigate errors or service failures
- Check logs from specific services
- Monitor resource usage (CPU, memory)
- Troubleshoot performance issues
- Verify service health status
- Analyze trends in metrics or logs
- Set up monitoring alerts

## LogQL Quick Reference

```logql
# Errors from Ollama in last 2 hours
{service="ollama"} |= "error" | json | __error__="" [2h]

# High memory usage warnings
{level="warn"} |~ "memory|OOM" [1h]

# Request latency over 1 second
{service="tc-backend"} | json | duration > 1s [30m]
```

## PromQL Quick Reference

```promql
# CPU usage by service
rate(process_cpu_seconds_total[5m]) * 100

# Memory usage
process_resident_memory_bytes / 1024 / 1024

# Request rate
rate(http_requests_total[5m])
```

## Reference Materials

For detailed guidance, see:
- @.claude/skills/observability/logql-cookbook.md
- @.claude/skills/observability/promql-cookbook.md
- @.claude/skills/observability/common-issues.md
- @.claude/skills/observability/alerting-rules.md

## Troubleshooting Workflows

### Workflow 1: Service Down
1. Check service status in Prometheus
2. Query recent logs in Loki for errors
3. Verify connectivity to dependencies
4. Check resource constraints (OOM, disk full)
5. Provide diagnosis and remediation steps

### Workflow 2: Performance Degradation
1. Compare current metrics to baseline
2. Identify resource bottlenecks
3. Analyze slow query logs (if DB)
4. Check for recent deployments/changes
5. Recommend optimizations
