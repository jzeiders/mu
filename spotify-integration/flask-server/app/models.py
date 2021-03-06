from sqlalchemy import Column, Integer, String, JSON
from app.database import Base
from app.database import db_session
import presets

class User(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True)
    name = Column(String(50), unique=True)
    playlists = Column(JSON)

    def __init__(self, name=None, playlists=None):
        self.name = name
        if playlists == None:
            self.playlists = dict()
            self.playlists["classifications"] = dict()
            self.playlists["classifications"]["focused"] = list()
            for song_id in presets.focused:
                self.playlists["classifications"]["focused"].append({
                    "song-id": song_id,
                    "song-rating": "50"
                })
            self.playlists["classifications"]["relaxed"] = list()
            for song_id in presets.relaxed:
                self.playlists["classifications"]["relaxed"].append({
                    "song-id": song_id,
                    "song-rating": "50"
                })
            self.playlists["classifications"]["hyped"] = list()
            for song_id in presets.hyped:
                self.playlists["classifications"]["hyped"].append({
                    "song-id": song_id,
                    "song-rating": "50"
                })


    def __repr__(self):
        return '<User %r>' % (self.name)

class TrainingData(Base):
    __tablename__ = "training_data"
    id = Column(Integer, primary_key=True)
    className = Column(String(50), unique=True)
    alpha = Column(JSON)
    beta = Column(JSON)
    delta = Column(JSON)
    gamma = Column(JSON)
    theta = Column(JSON)
    heart_rate = (Column(JSON))

    def __init__(self, className=None):
        self.className = className
        self.alpha = {}
        self.alpha["entries"] = list()
        self.beta = {}
        self.beta["entries"] = list()
        self.delta = {}
        self.delta["entries"] = list()
        self.gamma = {}
        self.gamma["entries"] = list()
        self.theta = {}
        self.theta["entries"] = list()
        self.heart_rate = {}
        self.heart_rate["entries"] = list()