from flask import Flask
from src.config import DevelopmentConfig
from src.db.connection import init_pool


def create_app(config_class=DevelopmentConfig):
    app = Flask(
        __name__,
        template_folder="templates",
        static_folder="../static"
    )

    app.config.from_object(config_class)

    init_pool(app)

    @app.get("/")
    def index():
        return "FCSMS is running successfully."

    return app