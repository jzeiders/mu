from flask import jsonify
import copy

from app import app

@app.route('/')
@app.route('/index')
def index():
    return "Hello, World!"
