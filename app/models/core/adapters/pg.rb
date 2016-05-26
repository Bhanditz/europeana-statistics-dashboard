class Core::Adapters::Pg

  require 'pg'
  # SQL queery to get list of all tables in the database.
  GET_ALL_TABLES = "SELECT table_name as name FROM information_schema.tables WHERE table_schema != 'pg_catalog' AND table_schema != 'information_schema';"

  # Returns a query string to get the name of all columns in a particular table.
  #
  # @param table_name [String] name of the table in database.
  # @return [String] SQL query string to fetch name of all columns.
  def self.query_get_all_columns(table_name)
    "SELECT column_name, data_type from information_schema.columns where table_name='#{table_name}';"
  end

  # Runs a SQL query string and retruns it's result.
  #
  # @param db [Object] an object of class Core::DbConnection.
  # @param query [String] the SQL query to execute.
  # @param format [String] the format of output data, ['json', '2darray', 'xml', 'raw'].
  # @return [Hash] metadata of data along with data as an object.
  def self.run(db, query, format, limit)
    response = {}
    begin
      connection = PG.connect(dbname: db.db_name, user: db.username, password: db.password, port: db.port, host: db.host)
      data = connection.exec(query)
      connection.close
      response["number_of_columns"] = data.nfields
      data = data.first(limit) unless limit.nil?
      response["number_of_rows"] = data.count
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