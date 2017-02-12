import os
basedir = os.path.abspath(os.path.dirname(__file__))

class Config(object):
    DEBUG = True
    TESTING = False
    CSRF_ENABLED = True
    SECRET_KEY = 'this-really-needs-to-be-changed'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_DATABASE_URI = os.environ['DB_URL']
    SQLALCHEMY_MIGRATE_REPO = os.path.join(basedir, 'db_repository')


class ProductionConfig(Config):
    DEBUG = True


class StagingConfig(Config):
    DEVELOPMENT = True
    DEBUG = True


class DevelopmentConfig(Config):
    DEVELOPMENT = True
    DEBUG = True


class TestingConfig(Config):
    TESTING = True
