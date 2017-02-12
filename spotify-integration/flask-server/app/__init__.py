import os
from flask import Flask
from flask_cors import CORS, cross_origin
from app.database import db_session


app = Flask(__name__)
CORS(app)
app.config.from_object(os.environ['APP_SETTINGS'])

@app.teardown_appcontext
def shutdown_session(exception=None):
    db_session.remove()

from app import views, models
