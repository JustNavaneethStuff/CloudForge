from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    app_env: str = "dev"
    app_port: int = 8000
    log_level: str = "INFO"

    db_host: str = "localhost"
    db_port: int = 5432
    db_name: str = "cloudforge"
    db_user: str = "cloudforge"
    db_password: str = "cloudforge"

    redis_host: str = "localhost"
    redis_port: int = 6379
    redis_ssl: bool = False
    redis_auth_token: str = ""

    metrics_enabled: bool = True
    otel_exporter_otlp_endpoint: str = ""
    otel_service_name: str = "cloudforge"

    @property
    def database_url(self) -> str:
        return (
            f"postgresql://{self.db_user}:{self.db_password}"
            f"@{self.db_host}:{self.db_port}/{self.db_name}"
        )

    @property
    def redis_url(self) -> str:
        scheme = "rediss" if self.redis_ssl else "redis"
        auth = f":{self.redis_auth_token}@" if self.redis_auth_token else ""
        return f"{scheme}://{auth}{self.redis_host}:{self.redis_port}/0"


@lru_cache
def get_settings() -> Settings:
    return Settings()
