import os 
import oracledb
import dotenv
dotenv.load_dotenv()

def get_connection():
    return oracledb.connect(
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        dsn=os.getenv(
            "DB_DSN",
            "localhost:1521/ORCL"
        )
    )
    import oracledb
from flask import current_app


def init_pool(app):
    pool = oracledb.create_pool(
        user=app.config["DB_USER"],
        password=app.config["DB_PASSWORD"],
        dsn=app.config["DB_DSN"],
        min=app.config["DB_POOL_MIN"],
        max=app.config["DB_POOL_MAX"],
        increment=app.config["DB_POOL_INCREMENT"],
        getmode=oracledb.POOL_GETMODE_TIMEDWAIT,
        wait_timeout=5000
    )

    app.extensions["oracle_pool"] = pool


def get_connection():
    pool = current_app.extensions["oracle_pool"]
    return pool.acquire()


def close_pool(app):
    pool = app.extensions.get("oracle_pool")

    if pool is not None:
        pool.close()
        app.extensions.pop("oracle_pool")