# Monitoring and Alerting

## Services

### Amazon CloudWatch

Central observability platform for logs, metrics, dashboards, and alarms.

**Components in CloudForge:**
| Component | Purpose |
|-----------|---------|
| Log Groups | ECS container stdout/stderr |
| Container Insights | ECS CPU, memory, network metrics |
| Dashboard | Unified operational view |
| Alarms | Proactive alerting via SNS |

**Tradeoff:** CloudWatch vs third-party (Datadog, Grafana Cloud) — native integration, no extra vendor, sufficient for portfolio.

### Amazon SNS

Notification fan-out for alarm actions. CloudForge uses email subscription.

**Tradeoff:** SNS email vs PagerDuty — email is free and demonstrates the pattern.

## Alarm Design

Alarms use `datapoints_to_alarm` to avoid false positives during deployments.
