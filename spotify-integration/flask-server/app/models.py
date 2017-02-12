from sqlalchemy import Column, Integer, String, JSON
from app.database import Base

class User(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True)
    name = Column(String(50), unique=True)
    playlists = Column(JSON)

    def __init__(self, name=None, playlists=None):
        self.name = name
        playlists["categories"] = []


    def __repr__(self):
        return '<User %r>' % (self.name)

class TrainingData(Base):
    __tablename__ = "training_data"
    id = Column(Integer, primary_key=True)
    name = Column(String(50), unique=True)
    data = Column(JSON)
