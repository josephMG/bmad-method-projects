"""Application configuration using Pydantic settings.
"""
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Pydantic settings for the application.
    """
    DATABASE_URL: str = "postgresql://user:password@localhost/db"
    SECRET_KEY: str = "a_very_secret_key"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    class Config:
        env_file = ".env"

settings = Settings()
