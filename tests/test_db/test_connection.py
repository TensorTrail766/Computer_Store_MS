from src import create_app
from src.db.connection import get_connection, close_pool
import dotenv

dotenv.load_dotenv()

def test_database_connection():
    app = create_app()

    try:
        with app.app_context():
            with get_connection() as connection:
                with connection.cursor() as cursor:
                    cursor.execute("SELECT 1 FROM DUAL")
                    result = cursor.fetchone()

                    assert result == (1,)
    finally:
        close_pool(app)