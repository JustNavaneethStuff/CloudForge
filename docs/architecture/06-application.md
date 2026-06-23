# FastAPI Application

## Design

CloudForge runs a **Python FastAPI** container on ECS Fargate behind an ALB.

### Endpoints

| Endpoint | Type | Purpose |
|----------|------|---------|
| `GET /health` | Liveness | Returns 200 if process is running (ALB health check) |
| `GET /ready` | Readiness | Checks DB + Redis connectivity (returns 503 if degraded) |
| `GET /api/v1/info` | API | Returns version and environment metadata |

### Configuration

Settings load from environment variables injected by ECS:
- Plain env vars for non-sensitive config (hosts, ports, names)
- Secrets Manager for `DB_PASSWORD` and `REDIS_AUTH_TOKEN`

### Logging

Structured JSON logs to stdout, collected by CloudWatch Logs via the ECS `awslogs` driver.

### Docker

Multi-stage build with non-root `appuser`, `curl` for health checks, and production `uvicorn` flags.

## Tradeoffs

| Choice | Rationale |
|--------|-----------|
| FastAPI | Async-ready, OpenAPI docs, modern Python |
| SQLAlchemy | Standard ORM, connection pooling with `pool_pre_ping` |
| Separate /health and /ready | ALB uses liveness; readiness catches dependency failures |
