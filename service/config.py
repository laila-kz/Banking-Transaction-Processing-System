import os
from dataclasses import dataclass


@dataclass
class DatabaseConfig:
    host: str = os.getenv("BANK_DB_HOST", "127.0.0.1")
    port: int = int(os.getenv("BANK_DB_PORT", "3306"))
    user: str = os.getenv("BANK_DB_USER", "root")
    password: str = os.getenv("BANK_DB_PASSWORD", "")
    database: str = os.getenv("BANK_DB_NAME", "bank_sys_final")
    pool_name: str = os.getenv("BANK_DB_POOL_NAME", "bank_service_pool")
    pool_size: int = int(os.getenv("BANK_DB_POOL_SIZE", "5"))


@dataclass
class APIConfig:
    host: str = os.getenv("BANK_API_HOST", "127.0.0.1")
    port: int = int(os.getenv("BANK_API_PORT", "5000"))
    debug: bool = os.getenv("BANK_API_DEBUG", "False").lower() in ("true", "1", "yes")
    env: str = os.getenv("BANK_ENV", "development")
