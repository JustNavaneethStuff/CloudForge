# Build stage
FROM python:3.12.8-slim-bookworm AS builder

WORKDIR /build

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

COPY pyproject.toml .
COPY src/ src/
RUN pip install --no-cache-dir --prefix=/install --no-deps .

# Runtime stage
FROM python:3.12.8-slim-bookworm

LABEL org.opencontainers.image.title="CloudForge API" \
      org.opencontainers.image.description="CloudForge FastAPI backend" \
      org.opencontainers.image.vendor="CloudForge" \
      org.opencontainers.image.source="https://github.com/CloudForge"

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl libpq5 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --shell /bin/bash appuser

WORKDIR /app

COPY --from=builder /install /usr/local

USER appuser

ENV APP_PORT=8000
EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:${APP_PORT}/health || exit 1

CMD ["uvicorn", "cloudforge.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1", "--proxy-headers", "--forwarded-allow-ips", "*"]
