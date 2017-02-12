from sqlalchemy import Column, Integer, String, JSON
from app.database import Base
from app.database import db_session

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