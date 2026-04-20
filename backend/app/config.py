from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    database_url: str = "postgresql+asyncpg://postgres:postgres@localhost:5432/lantern_sage"
    redis_url: str = "redis://localhost:6379/0"

    zhipu_api_key: str = ""
    zhipu_base_url: str = "https://open.bigmodel.cn/api/paas/v4/"
    zhipu_model: str = "glm-4-flash"

    daily_read_cache_ttl: int = 86400
    mvp_unrestricted: bool = True
    free_daily_ask_limit: int = 2
    mvp_daily_ask_limit: int = 999
    free_history_days: int = 7
    mvp_history_days: int = 30
    plus_history_days: int = 30

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}


settings = Settings()
