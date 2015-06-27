class Core::UploadFromFTP::UploadWorker

  include Sidekiq::Worker
  sidekiq_options :backtrace => true

  def perform(obj_id)
    obj = Core::DataStorePull.find(obj_id)
    obj.update_attributes({status: "<span style='color: orangered;'>Pending</span>"})
    url = obj.file_url
    file_name = "#{url.split("/")[-1]}"
    file_path = "/tmp/#{file_name}"
    api_token = obj.core_project.core_tokens.first.api_token
    first_row_header = obj.first_row_header
    if system("wget #{url} -O #{file_path}")
      obj.update_attributes({status: "<span style='color: green;'>Pulling...</span>"})
      headers = File.open(file_path, &:readline)
      column_separator = ["\t", "|", ";", ","].sort_by{|separator| headers.count(separator)}.last
      begin
        Core::DataStore.upload_or_create_file(file_path, file_name, obj.core_project_id, first_row_header, column_separator, api_token)
        obj.update_attributes({status: "completed"})
        obj.delete
      rescue Exception => e
        obj.update_attributes({status: "<span style='color:red;'>Failed</span>", error_messages: e})
      end
    else
      obj.update_attributes({status: "<span style='color:red;'>Failed</span>", error_messages: "Failed to fetch data"})
    end
    File.delete(file_path)
  end
end