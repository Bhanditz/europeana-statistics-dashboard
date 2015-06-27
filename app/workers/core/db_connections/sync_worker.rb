class Core::DbConnections::SyncWorker
  
  include Sidekiq::Worker
  sidekiq_options :backtrace => true

  def perform(core_db_connection_id)
    db = Core::DbConnection.find(core_db_connection_id)
    query = Core::Adapters::DB.query_get_all_tables("pg")
    response = Core::Adapters::DB.run(db, query, "raw", "pg")
    response = response["query_output"]
    response.each do |table_name|
      query = "Select * from #{table_name['name']}"
      query_get_all_columns = Core::Adapters::DB.query_get_all_columns(table_name['name'], "pg")
      column_with_type = Core::Adapters::DB.run(db, query_get_all_columns, "raw", "pg")
      column_with_type = column_with_type["query_output"]
      col = {}
      column_with_type.each do |c|
        col_name, col_data_type = c["column_name"], c["data_type"]
        d_or_m = "d"
        case col_data_type
        when "character varying"
          col_data_type = "string"
        when "integer"
          col_data_type = "integer"
          d_or_m = "m"
        when "double precision"
          col_data_type = "double"
          d_or_m = "m"
        when "boolean"
          col_data_type = "boolean"
        when "date"
          col_data_type = "date"
        end
        col[col_name] = {"data_type": col_data_type,"d_or_m": d_or_m}
      end
      datacast = Core::Datacast.create_or_update_by(query,db.core_project_id,db.id,table_name['name'],col)
    end
  end
end