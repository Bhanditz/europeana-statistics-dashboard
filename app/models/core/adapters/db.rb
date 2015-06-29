class Core::Adapters::Db
  def self.query_get_all_tables(adapter)
    if adapter == "postgresql"
      return Core::Adapters::Pg::GET_ALL_TABLES
    end
  end
  
  def self.query_get_all_columns(table_name, adapter)
    if adapter == "postgresql"
      return Core::Adapters::Pg::query_get_all_columns(table_name)
    end
  end
  
  def self.run(db, query, format,limit=nil)
    if db.adapter == "postgresql"
      return  Core::Adapters::Pg.run(db, query, format, limit)
    end
  end
  
end