class Core::DataStore
  #GEMS
  #CONSTANTS
  #ATTRIBUTES  
  #ACCESSORS
  attr_accessor :core_project_id, :name, :table_name, :account_id, :db_connection_id

  #ASSOCIATIONS
  #VALIDATIONS
  #CALLBACKS
  #SCOPES
  #CUSTOM SCOPES
  #OTHER
  
  def self.create_grid(projectname, username, filename, token, grid_data, first_row_header=true)
    begin
      response = Nestful.post REST_API_ENDPOINT + "#{username}/#{projectname}/#{filename}/grid/create", {:token => token, :data => grid_data, :first_row_header => first_row_header }, :format => :json
      if response.status == 201
        return true
      else
        return false
      end
    rescue Exception => e
      return false
    end
  end
  
  def self.upload_tmp_file(_data)
    uploader = CsvFileUploader.new
    if uploader.cache!(_data)
      file_path = uploader.file.path
      file_size = uploader.file.size
      if !file_path or file_size < 1
        return [uploader, "File is empty.", nil] 
      end
    else
      return [uploader, "File is not uploaded.", nil]
    end
    headers = File.open(file_path, &:readline) 
    begin 
      column_separator = ["\t", "|", ";", ","].sort_by{|separator| headers.count(separator)}.last
    rescue => e
      return [uploader, e.to_s, nil]
    end
    return [uploader, nil, column_separator]
  end

  def self.upload_or_create_file(file_path, file_name, _core_project_id, first_row_header, column_separator, token)
    d = Core::DataStore.new({name: file_name, core_project_id: _core_project_id})
    if d.save
      grid_data = []
      is_everything_saved_properly = false
      begin
        CSV.foreach(file_path, {:col_sep => column_separator, :skip_blanks => true}) do |row|
          grid_data << row
          if $. == 2
            is_everything_saved_properly = Core::DataStore.create_grid(d.core_project.slug, d.core_project.account.slug, d.slug, token, grid_data, first_row_header)
            break if !is_everything_saved_properly
            grid_data = []
          elsif $. % 100 == 0 and $. > 0
            is_everything_saved_properly = Core::DataStore.insert_into_grid(d.core_project.slug, d.core_project.account.slug, d.slug, token, grid_data)
            break if !is_everything_saved_properly
            grid_data = []
          end
        end
        if !grid_data.empty?
          is_everything_saved_properly = Core::DataStore.insert_into_grid(d.core_project.slug, d.core_project.account.slug, d.slug, token, grid_data)
        end
      rescue
        is_everything_saved_properly = false
      end
      if is_everything_saved_properly
        return d
      else
        d.destroy
        return nil
      end
    else
      return nil
    end
  end

  def self.insert_into_grid(projectname, username, filename, token, grid_data)
    begin
      response = Nestful.post REST_API_ENDPOINT + "#{username}/#{projectname}/#{filename}/row/batch_add", {token: token, data: grid_data }, :format => :json
      if response.status == 201
        return true
      else
        return false
      end
    rescue Exception => e
      return false
    end
  end
  
  def to_s
    self.name
  end
  
  #FUNCTIONS
  #PRIVATE
  private
  
end
