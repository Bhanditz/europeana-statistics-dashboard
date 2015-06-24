class Core::S3File::DestroyWorker
  
  include Sidekiq::Worker
  sidekiq_options :backtrace => true
  
  def perform(object_type, object_id)
    if object_type == "DataStore"
      obj = Core::DataStore.find(object_id)
    end
    begin
      if obj.core_project.cdn_source == "s3"
        s3 = Constants::S3
        s3.buckets[Constants::AMAZON_S3_BUCKET].objects[obj.s3_file_name].delete
      else
        access_token = Nestful::Request.new(Constants::SOFTLAYER_OBJECT_STORAGE_SINGAPORE_URL,headers: {"X-Auth-User" => Constants::SOFTLAYER_USERID,"X-Auth-Key" => Constants::SOFTLAYER_API_KEY}).execute.headers["x-auth-token"]
        delete_command = "curl -i #{obj.cdn_published_url} -X DELETE -H \"X-Auth-Token: #{access_token}\""
        system(delete_command)
      end
      obj.delete
    rescue Exception => e
      obj.update_attributes(cdn_published_error: e.to_s)
    end
  end
  
end