import logging
from typing import Any

from pythonjsonlogger.json import JsonFormatter
from redis import Redis
from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine
from sqlalchemy.exc import SQLAlchemyError

from cloudforge.config import Settings

logger = logging.getLogger(__name__)


def configure_logging(level: str) -> None:
    handler = logging.StreamHandler()
    handler.setFormatter(JsonFormatter("%(asctime)s %(name)s %(levelname)s %(message)s"))
    root = logging.getLogger()
    root.handlers.clear()
    root.addHandler(handler)
    root.setLevel(level)


def create_db_engine(settings: Settings) -> Engine:
    return create_engine(
        settings.database_url,
        pool_pre_ping=True,
        pool_size=5,
        max_overflow=10,
    )


def create_redis_client(settings: Settings) -> Redis:  # type: ignore[type-arg]
    return Redis.from_url(
        settings.redis_url,
        decode_responses=True,
        socket_connect_timeout=5,
        socket_timeout=5,
        ssl_cert_reqs=None if settings.redis_ssl else None,
    )


def check_database(engine: Engine) -> dict[str, Any]:
    try:
        with engine.connect() as connection:
            connection.execute(text("SELECT 1"))
        return {"status": "ok"}
    except SQLAlchemyError as exc:
        logger.warning("database health check failed", extra={"error": str(exc)})
        return {"status": "error", "detail": str(exc)}


def check_redis(client: Redis) -> dict[str, Any]:  # type: ignore[type-arg]
    try:
        if not client.ping():
            return {"status": "error", "detail": "ping returned false"}
        return {"status": "ok"}
    except Exception as exc:  # noqa: BLE001
        logger.warning("redis health check failed", extra={"error": str(exc)})
        return {"status": "error", "detail": str(exc)}
