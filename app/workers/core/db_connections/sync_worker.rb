class Core::DbConnections::SyncWorker
  
  include Sidekiq::Worker
  sidekiq_options :backtrace => true

  def perform(core_db_connection_id)
    db = Core::DbConnection.find(core_db_connection_id)
    query = Core::Adapters::Db.query_get_all_tables("postgresql")
    all_tables = Core::Adapters::Db.run(db, query, "raw")
    all_tables_data = all_tables["query_output"]
    all_tables_data.each do |table_name|
      query = "Select * from #{table_name['name']}"
      datacast = Core::Datacast.create_or_update_by(query,db.core_project_id,db.id,table_name['name'])
    end
  end
end