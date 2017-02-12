from flask import jsonify, request
import copy

from app import app
from app.database import db_session
from models import TrainingData

from sqlalchemy.orm.attributes import flag_modified

@app.route('/')
@app.route('/index')
def index():
    return "Hello, World!"

@app.route('/clear', methods=["POST"])
def clear():
    classification = request.form["class"]

    classf = db_session.query(TrainingData).filter(TrainingData.className == str(classification)).first()
    if classf != None:
        classf.alpha = {}
        classf.alpha["entries"] = list()
        classf.beta = {}
        classf.beta["entries"] = list()
        classf.delta = {}
        classf.delta["entries"] = list()
        classf.gamma = {}
        classf.gamma["entries"] = list()
        classf.theta = {}
        classf.theta["entries"] = list()

        flag_modified(classf, "alpha")
        flag_modified(classf, "beta")
        flag_modified(classf, "gamma")
        flag_modified(classf, "delta")
        flag_modified(classf, "theta")
        db_session.commit()

        resp = jsonify(**{})
        resp.status_code = 200
        return resp
    else:
        resp = jsonify(**{"message": "class does not exist"})
        resp.status_code = 434
        return resp

@app.route('/classification/<string:classification>', methods=["GET"])
def getClass(classification):
    classf = db_session.query(TrainingData).filter(TrainingData.className == str(classification)).first()
    if classf != None:
        jsonObj = dict()
        jsonObj["class"] = classification
        jsonObj["alpha"] = classf.alpha["entries"]
        jsonObj["beta"] = classf.beta["entries"]
        jsonObj["delta"] = classf.delta["entries"]
        jsonObj["gamma"] = classf.gamma["entries"]
        jsonObj["theta"] = classf.theta["entries"]
        
        resp = jsonify(**jsonObj)
        resp.status_code = 200
        return resp
    else:
        resp = jsonify(**{"message": "class does not exist"})
        resp.status_code = 434
        return resp

@app.route('/classification', methods=["GET", "POST", "PUT"])
def classification():
    if request.method == "PUT":
        return putClass(request)
    elif request.method == "GET":
        return getClass(request)
    elif request.method == "POST":
        return postClass(request)
    else:
        abort(404)

def postClass(request):
    jsonPost = request.get_json()
    print jsonPost
    classification = jsonPost[u"class"]
    alpha = jsonPost[u"alpha"]
    beta = jsonPost[u"beta"]
    gamma = jsonPost[u"gamma"]
    delta = jsonPost[u"delta"]
    theta = jsonPost[u"theta"]

    classf = db_session.query(TrainingData).filter(TrainingData.className == str(classification)).first()
    if classf != None:
        classf.alpha["entries"].extend(alpha)
        classf.beta["entries"].extend(beta)
        classf.delta["entries"].extend(delta)
        classf.gamma["entries"].extend(gamma)
        classf.theta["entries"].extend(theta)

        flag_modified(classf, "alpha")
        flag_modified(classf, "beta")
        flag_modified(classf, "gamma")
        flag_modified(classf, "delta")
        flag_modified(classf, "theta")
        db_session.commit()

        resp = jsonify(**{})
        resp.status_code = 200
        return resp

    else:
        resp = jsonify(**{"message": "class does not exist"})
        resp.status_code = 434
        return resp


    
    return str(200)

def putClass(request):
    classification = request.form["class"]

    #Check if classification exists
    if len(db_session.query(TrainingData).filter(TrainingData.className == str(classification)).all()) == 0:
        new_class = TrainingData(classification)
        db_session.add(new_class)
        db_session.commit()
        resp = jsonify(**{})
        resp.status_code = 200
        return resp
    else:
        resp = jsonify(**{})
        resp.status_code = 429
        return resp

def getClass(request):
    return str(200)
