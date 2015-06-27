class Core::Adapters::DB
  
  def self.query_get_all_tables(adapter)
    if adapter == "pg"
      return Core::Adapters::Pg::GET_ALL_TABLES
    end
  end
  
  def self.query_get_all_columns(table_name, adapter)
    if adapter == "pg"
      Core::Adapters::Pg::query_get_all_columns(table_name)
    end
  end
  
  def self.run(db, query, format, adapter)
    if adapter == "pg"
      Core::Adapters::Pg.run(db, query, format)
    end
  end
  
end