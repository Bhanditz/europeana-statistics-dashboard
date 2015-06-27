class Core::Adapters::Pg
  
  require 'pg'
  
  GET_ALL_TABLES = "SELECT table_name as name FROM information_schema.tables WHERE table_schema != 'pg_catalog' AND table_schema != 'information_schema';"
  
  def self.query_get_all_columns(table_name)
    "SELECT column_name, data_type from information_schema.columns where table_name='#{table_name}';"
  end
  
  def self.run(db, query, format)
    response = {}
    begin
      connection = PG.connect(dbname: db.db_name, user: db.username, password: db.password, port: db.port, host: db.host)
      data = connection.exec(query)
      connection.close
      response["number_of_rows"] = data.ntuples
      response["number_of_columns"] = data.nfields
      response["query_output"] = format == "2darray" ? Core::DataTransform.twod_array_generate(data) 
                               : format == "json"    ? Core::DataTransform.json_generate(data) 
                               : format == "xml"     ? Core::DataTransform.json_generate(data, true) 
                               : format == "raw"     ? data
                                                     : Core::DataTransform.csv_generate(data)
      response["execute_flag"] = true
    rescue => e
      response["query_output"] = e.to_s
      response["execute_flag"] = false
    end
    return response
  end
  
end