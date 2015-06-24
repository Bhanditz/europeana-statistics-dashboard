from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, String, DateTime
from database import DB_CONFIG
from hstore import Hstore
from sqlalchemy.dialects.postgresql import JSON

Base = declarative_base()

class DataStores(Base):
    __tablename__ = "data_stores"

    id = Column(Integer, primary_key=True)
    core_project_id = Column(Integer)
    name = Column(String(255))
    slug = Column(String(255))
    #content = Column(JSON)
    core_query_id = Column(Integer)
    properties = Column(Hstore, nullable=False, default={})
    created_at = Column(DateTime)
    updated_at = Column(DateTime)
    #content_text = Column(String)
    parent_id = Column(Integer)
    core_authentication_id = Column(Integer)

    def __repr__(self):
        return  self.name