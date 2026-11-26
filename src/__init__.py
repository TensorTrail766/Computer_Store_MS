from flask import Flask
from src.config import DevelopmentConfig


def create_app(config_class=DevelopmentConfig):

    app = Flask(
        __name__,
        template_folder="templates",
        static_folder="../static"
    )

    app.config.from_object(config_class)

    @app.get("/")
    def index():
        return "FCSMS is running successfully."

    return app