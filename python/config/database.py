import yaml


CURRENT_ENVIRONMENT = 'development'


stream = open('../../config/database.yml', 'r')
db_config = yaml.load(stream)

if CURRENT_ENVIRONMENT == 'development':
    db_config = db_config['development']
elif CURRENT_ENVIRONMENT =='production':
    db_config = db_config['production']

DB_CONFIG = "postgresql+psycopg2" + "://" + db_config['username'] + ":" + db_config['password'] + "@" + \
            db_config['host'] + ":" + str(db_config['port']) + "/" + db_config['database']

stream.close()

stream = open('../../config/mongoid.yml', 'r')
db_config = yaml.load(stream)

if CURRENT_ENVIRONMENT == 'development':
    db_config = db_config['development']['sessions']['default']
elif CURRENT_ENVIRONMENT =='production':
    db_config = db_config['production']['sessions']['default']

MONGO_DB_CONFIG = db_config
stream.close()

