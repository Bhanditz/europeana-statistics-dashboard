class Core::DataTransform

  def self.twod_array_generate(object)
    # Convert PG::Result object to 2d array
    final_data = []
    begin
      final_data << object[0].keys
    rescue IndexError => e
      return []
    end
    object.each do |row|
      final_data << row.values
    end
    return final_data
  end

  def self.json_generate(object)
    # Convert PG::Result object to JSON
    final_data = []
    object.each do |row|
      final_data << row
    end
    return final_data.to_json
  end

  def self.csv_generate(object)
    # Convert PG::Result object to CSV
    final_data = ""
    begin
      headers = object[0].keys
      final_data += headers.to_csv
      object.each do |row|
        row = row.values
        final_data += row.to_csv
      end
      final_data = final_data[0...-1] #removing the last extra \n
    rescue IndexError => e
      return ""
    end
    return final_data
  end

  def self.pg(db)
    require 'pg'
    connection = PG.connect(dbname: db.db_name, user: db.username, password: db.password, port: db.port, host: db.host)
    query = "SELECT table_name as name
             FROM information_schema.tables
             WHERE table_schema != 'pg_catalog' AND table_schema != 'information_schema';"
    result = connection.exec(query)
    connection.close
    return result
  end

  def self.get_column_types(db, table_name)
    require 'pg'
    connection = PG.connect(dbname: db.db_name, user: db.username, password: db.password, port: db.port, host: db.host)
    query = "SELECT column_name, data_type from information_schema.columns where table_name='#{table_name}';"
    result = connection.exec(query)
    connection.close
    return result
  end

end
