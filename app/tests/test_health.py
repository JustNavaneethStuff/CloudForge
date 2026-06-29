from unittest.mock import MagicMock, patch

import pytest
from fastapi.testclient import TestClient

from cloudforge.main import create_app


@pytest.fixture
def client() -> TestClient:
    with patch("cloudforge.main.create_db_engine") as mock_db, patch(
        "cloudforge.main.create_redis_client"
    ) as mock_redis:
        mock_db.return_value = MagicMock()
        mock_redis.return_value = MagicMock()
        app = create_app()
        with TestClient(app) as test_client:
            yield test_client


def test_health_returns_ok(client: TestClient) -> None:
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_info_returns_metadata(client: TestClient) -> None:
    response = client.get("/api/v1/info")
    assert response.status_code == 200
    body = response.json()
    assert body["name"] == "CloudForge"
    assert "version" in body
    assert "environment" in body


def test_ready_returns_503_when_dependencies_fail(client: TestClient) -> None:
    with patch("cloudforge.health.check_database", return_value={"status": "error"}), patch(
        "cloudforge.health.check_redis", return_value={"status": "error"}
    ):
        response = client.get("/ready")
    assert response.status_code == 503
    assert response.json()["status"] == "degraded"


def test_ready_returns_200_when_dependencies_ok(client: TestClient) -> None:
    with patch("cloudforge.health.check_database", return_value={"status": "ok"}), patch(
        "cloudforge.health.check_redis", return_value={"status": "ok"}
    ):
        response = client.get("/ready")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_metrics_endpoint_returns_prometheus_format(client: TestClient) -> None:
    response = client.get("/metrics")
    assert response.status_code == 200
    assert "http_requests_total" in response.text
