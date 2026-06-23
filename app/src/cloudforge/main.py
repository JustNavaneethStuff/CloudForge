from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import FastAPI

from cloudforge import __version__
from cloudforge.config import get_settings
from cloudforge.db import configure_logging, create_db_engine, create_redis_client
from cloudforge.health import api_router
from cloudforge.health import router as health_router


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    settings = get_settings()
    configure_logging(settings.log_level)
    app.state.settings = settings
    app.state.db_engine = create_db_engine(settings)
    app.state.redis_client = create_redis_client(settings)
    yield
    app.state.redis_client.close()
    app.state.db_engine.dispose()


def create_app() -> FastAPI:
    app = FastAPI(
        title="CloudForge API",
        version=__version__,
        description="Cloud infrastructure platform API",
        lifespan=lifespan,
    )
    app.include_router(health_router)
    app.include_router(api_router)
    return app


app = create_app()
