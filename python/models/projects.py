from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, String, Boolean, DateTime
from hstore import Hstore

Base = declarative_base()

class Projects(Base):
    __tablename__ = "projects"

    id = Column(Integer, primary_key=True)
    account_id = Column(Integer)
    name = Column(String(255))
    slug = Column(String(255))
    properties = Column(Hstore, nullable=False, default={})
    is_public = Column(Boolean)
    created_at = Column(DateTime)
    updated_at = Column(DateTime)

    def __repr__(self):
        return self.name, self.id