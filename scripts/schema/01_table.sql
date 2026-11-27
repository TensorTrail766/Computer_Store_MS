from src.db.connection import get_connection 



def create_table():
    connection = get_connection()
    cursor = connection.cursor()

    create_table_query = """
    CREATE TABLE IF NOT EXISTS users (
        user_id number (19,0) PRIMARY KEY,
        username VARCHAR(50) NOT NULL UNIQUE,
        email VARCHAR(100) NOT NULL UNIQUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        password_hash VARCHAR(255) NOT NULL
        role VARCHAR(100) NOT NULL
        full_name VARCHAR(100) NOT NULL
        phone_number number(10) NOT NULL
        is_active BOOLEAN (1,0) default true
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        last_login TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    """

    cursor.execute(create_table_query)
    connection.commit()
    cursor.close()
    connection.close()
