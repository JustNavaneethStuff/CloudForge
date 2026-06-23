from fastapi import APIRouter, Request
from fastapi.responses import JSONResponse

from cloudforge import __version__
from cloudforge.config import Settings
from cloudforge.db import check_database, check_redis

router = APIRouter(tags=["health"])


@router.get("/health")
def liveness() -> dict[str, str]:
    return {"status": "ok"}


@router.get("/ready")
def readiness(request: Request) -> JSONResponse:
    settings: Settings = request.app.state.settings
    db_result = check_database(request.app.state.db_engine)
    redis_result = check_redis(request.app.state.redis_client)

    healthy = db_result["status"] == "ok" and redis_result["status"] == "ok"
    body = {
        "status": "ok" if healthy else "degraded",
        "environment": settings.app_env,
        "checks": {
            "database": db_result,
            "redis": redis_result,
        },
    }
    return JSONResponse(status_code=200 if healthy else 503, content=body)


api_router = APIRouter(prefix="/api/v1", tags=["api"])


@api_router.get("/info")
def info(request: Request) -> dict[str, str]:
    settings: Settings = request.app.state.settings
    return {
        "name": "CloudForge",
        "version": __version__,
        "environment": settings.app_env,
    }
