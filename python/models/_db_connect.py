from sqlalchemy import create_engine
from database import DB_CONFIG
from pymongo import MongoClient
from database import MONGO_DB_CONFIG

def db_connect():
    #Pool Size Ref - http://docs.sqlalchemy.org/en/rel_0_9/core/pooling.html#connection-pool-configuration
    return create_engine(DB_CONFIG, echo=False, pool_size=1)

def mongo_connect():
    #MONGOHQ_URL=mongodb://user:pass@server.compose.io/database_name
    #host = MONGO_DB_CONFIG['hosts'][0].split(":")[0]
    #port = MONGO_DB_CONFIG['hosts'][0].split(":")[1]
    dbname = MONGO_DB_CONFIG['database']
    MONGOHQ_URL = "mongodb://" + MONGO_DB_CONFIG['username'] + ":" +MONGO_DB_CONFIG['password'] + "@" + MONGO_DB_CONFIG['hosts'][0]
    print MONGOHQ_URL
    client = MongoClient(MONGOHQ_URL)
    client = client[dbname]
    return client