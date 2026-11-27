import os
from dotenv import load_dotenv

load_dotenv()


class Config:
    SECRET_KEY = os.getenv("SECRET_KEY")

    DB_USER = os.getenv("DB_USER")
    DB_PASSWORD = os.getenv("DB_PASSWORD")
    DB_DSN = os.getenv("DB_DSN")

    DB_POOL_MIN = int(os.getenv("DB_POOL_MIN", "2"))
    DB_POOL_MAX = int(os.getenv("DB_POOL_MAX", "10"))
    DB_POOL_INCREMENT = int(os.getenv("DB_POOL_INCREMENT", "1"))


class DevelopmentConfig(Config):
    DEBUG = True


class ProductionConfig(Config):
    DEBUG = False


class TestingConfig(Config):
    TESTING = True
    DEBUG = False