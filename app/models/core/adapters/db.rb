# frozen_string_literal: true
class Core::Adapters::Db
  # (see Core::Adapters::Pg#query_get_all_columns)
  # @note accepts a param adapter that is the database adapter to be used.
  def self.query_get_all_columns(table_name, adapter)
    if adapter == 'postgresql'
      return Core::Adapters::Pg.query_get_all_columns(table_name)
    end
  end

  # (see Core::Adapters::Pg#run)
  # @note param limit has default value nil.
  def self.run(db, query, format, limit = nil)
    if db.adapter == 'postgresql'
      return Core::Adapters::Pg.run(db, query, format, limit)
    end
  end
end
