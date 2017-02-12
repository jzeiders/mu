from flask import jsonify, request
import copy

from app import app, sc_client
from app.database import db_session
from models import TrainingData, User

from sqlalchemy.orm.attributes import flag_modified

@app.route('/')
@app.route('/index')
def index():
    return "Hello, World!"

@app.route('/user', methods=["PUT", "POST"])
def user():
    if request.method == "POST":
        return postUser(request)
    elif request.method == "PUT":
        return putUser(request)

def putUser(request):
    username = str(request.form["username"])
    user = db_session.query(User).filter(User.name == str(username)).first()
    if user == None:
        newUser = User(username)
        db_session.add(newUser)
        db_session.commit()
        resp = jsonify(**{"New User" : username})
        resp.status_code = 200
        return resp
    else:
        resp = jsonify(**{"Failed" : "User already exists"})
        resp.status_code = 455
        return resp

def postUser(request):
    user = str(request.form["user"])
    userf = db_session.query(User).filter(User.name == str(user)).first()
    if userf != None:
        classification = str(request.form["classification"])
        song_id = str(request.form["song-id"])
        song_rating = str(request.form["song-rating"])

        song = dict()
        song["song-id"] = song_id
        song["song-rating"] = song_rating

        if classification not in userf.playlists["classifications"]:
            userf.playlists["classifications"][classification] = list()
            userf.playlists["classifications"][classification].append(song)
        else:
            userf.playlists["classifications"][classification].append(song)
        
        flag_modified(userf, "playlists")
        db_session.commit()

        resp = jsonify(**{})
        resp.status_code = 200
        return resp
    else:
        resp = jsonify(**{"message": "user does not exist"})
        resp.status_code = 434
        return resp        


@app.route('/clear', methods=["POST"])
def clear():
    classification = str(request.form["class"])

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
        classf.heart_rate = {}
        classf.heart_rate["entries"] = list()

        flag_modified(classf, "alpha")
        flag_modified(classf, "beta")
        flag_modified(classf, "gamma")
        flag_modified(classf, "delta")
        flag_modified(classf, "theta")
        flag_modified(classf, "heart_rate")
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
        jsonObj["heart_rate"] = classf.heart_rate["entries"]
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
    classification = str(jsonPost[u"class"])
    alpha = jsonPost[u"alpha"]
    beta = jsonPost[u"beta"]
    gamma = jsonPost[u"gamma"]
    delta = jsonPost[u"delta"]
    theta = jsonPost[u"theta"]
    heart_rate = jsonPost[u"heart_rate"]

    classf = db_session.query(TrainingData).filter(TrainingData.className == str(classification)).first()
    if classf != None:
        classf.alpha["entries"].extend(alpha)
        classf.beta["entries"].extend(beta)
        classf.delta["entries"].extend(delta)
        classf.gamma["entries"].extend(gamma)
        classf.theta["entries"].extend(theta)
        classf.heart_rate["entries"].extend(heart_rate)

        flag_modified(classf, "alpha")
        flag_modified(classf, "beta")
        flag_modified(classf, "gamma")
        flag_modified(classf, "delta")
        flag_modified(classf, "theta")
        flag_modified(classf, "heart_rate")
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

@app.route('/playlist', methods=["GET"])
def playlist():
    if request.method == "GET":
        return getPlaylist(request)

def getPlaylist(request):
    username = str(request.args.get("username"))
    classification = str(request.args.get("classification"))
    print "User: " + username
    print "Classification: " + classification

    user = db_session.query(User).filter(User.name == username).first()

    if user == None:
        resp = jsonify(**{"Failed": "User does not exist"})
        resp.status_code = 467
        return resp

    if classification in user.playlists["classifications"]:
        playlist = user.playlists["classifications"][classification]
        print playlist
        jsonData = dict()
        jsonData["playlist"] = playlist
        resp = jsonify(**jsonData)
        resp.status_code = 200
        return resp
    else:
        resp = jsonify(**{"Failed": "User has no playlist data"})
        resp.status_code = 467
        return resp

@app.route('/hyped', methods=["GET"])
def get_hyped():
    newTracks = sc_client.get('/tracks', genre="edm", limit="50")
    
    jsonOut = dict()
    jsonOut["playlist"] = list()

    for track in newTracks:
        jsonOut["playlist"].append({
            "song-rating": "60",
            "song-id":track.id
        })
    
    resp = jsonify(**jsonOut)
    resp.status_code = 200
    return resp

@app.route('/relaxed', methods=["GET"])
def get_relaxed():
    newTracks = sc_client.get('/tracks', genre="pop", limit="50")
    
    jsonOut = dict()
    jsonOut["playlist"] = list()

    for track in newTracks:
        jsonOut["playlist"].append({
            "song-rating": "60",
            "song-id":track.id
        })
    
    resp = jsonify(**jsonOut)
    resp.status_code = 200
    return resp

@app.route('/focused', methods=["GET"])
def get_focused():
    newTracks = sc_client.get('/tracks', genre="piano", limit="50")
    
    jsonOut = dict()
    jsonOut["playlist"] = list()

    for track in newTracks:
        jsonOut["playlist"].append({
            "song-rating": "60",
            "song-id":track.id
        })
    
    resp = jsonify(**jsonOut)
    resp.status_code = 200
    return resp


