from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, String, DateTime
from hstore import Hstore

Base = declarative_base()

class CoreMetadataDataStoreColumns(Base):
    __tablename__ = "core_metadata_data_store_columns"

    id = Column(Integer, primary_key=True)
    data_store_id = Column(Integer)
    column_name = Column(String(255))
    datatype = Column(String(255))
    properties = Column(Hstore, nullable=False, default={})
    created_at = Column(DateTime)
    updated_at = Column(DateTime)

    def __repr__(self):
        return  self.column_name