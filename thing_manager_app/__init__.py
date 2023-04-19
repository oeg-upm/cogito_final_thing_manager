from flask import Flask


def create_app():
    app = Flask(__name__)

    app.config['SECRET_KEY'] = 'e7a531d550fe431c86375f4968f5c142'

    from .blueprints.shutdown import shutdown as shutdown_blueprint
    app.register_blueprint(shutdown_blueprint)

    from .blueprints.file import file_blu as file_blueprint
    app.register_blueprint(file_blueprint)

    from .blueprints.project import project as project_blueprint
    app.register_blueprint(project_blueprint)


    return app
