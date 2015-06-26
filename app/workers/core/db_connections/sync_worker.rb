class Core::DbConnections::SyncWorker
  
  include Sidekiq::Worker
  sidekiq_options :backtrace => true

  def perform(core_db_connection_id)
    db = Core::DbConnection.find(core_db_connection_id)
    db = Core::DbConnection.last
    response = Core::DataTransform.pg(db)
    response.each do |table_name|
      query = "Select * from #{table_name['name']}"
      column_with_type = Core::DataTransform.get_column_types(db, table_name['name'])
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