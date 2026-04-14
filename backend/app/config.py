from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    database_url: str = "postgresql+asyncpg://postgres:postgres@localhost:5432/lantern_sage"
    redis_url: str = "redis://localhost:6379/0"

    deepseek_api_key: str = ""
    deepseek_base_url: str = "https://api.deepseek.com"
    deepseek_model: str = "deepseek-chat"

    daily_read_cache_ttl: int = 86400
    free_daily_ask_limit: int = 2
    free_history_days: int = 7
    plus_history_days: int = 30

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}


settings = Settings()
