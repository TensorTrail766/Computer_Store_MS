import os 
import oracledb

def get_connection():
    return oracledb.connect(
        user=os.getenv("ORACLE_USER"),
        password=os.getenv("ORACLE_PASSWORD"),
        dsn=os.getenv(
            "ORACLE_DSN",
            "localhost:1521/ORCL"
        )
    )