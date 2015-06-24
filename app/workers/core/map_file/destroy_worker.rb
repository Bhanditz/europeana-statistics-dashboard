class Core::MapFile::DestroyWorker
  
  include Sidekiq::Worker
  sidekiq_options :backtrace => true
  
  def perform(object_id)
    obj = Core::MapFile.find(object_id)
    begin
      access_token = Nestful::Request.new(Constants::SOFTLAYER_OBJECT_STORAGE_SINGAPORE_URL,headers: {"X-Auth-User" => Constants::SOFTLAYER_USERID,"X-Auth-Key" => Constants::SOFTLAYER_API_KEY}).execute.headers["x-auth-token"]
      delete_command = "curl -i #{obj.cdn_published_url} -X DELETE -H \"X-Auth-Token: #{access_token}\""
      system(delete_command)
      obj.destroy
    rescue Exception => e
      obj.update_attributes(cdn_published_error: e.to_s)
    end
  end
end