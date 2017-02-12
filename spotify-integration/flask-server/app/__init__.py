import os
import soundcloud
from flask import Flask
from flask_cors import CORS, cross_origin
from app.database import db_session


app = Flask(__name__)
CORS(app)
app.config.from_object(os.environ['APP_SETTINGS'])

# connect to Soundcloud API
sc_client = soundcloud.Client(
    client_id=os.environ["SC_CLIENT_ID"]
)

@app.teardown_appcontext
def shutdown_session(exception=None):
    db_session.remove()

from app import views, models
