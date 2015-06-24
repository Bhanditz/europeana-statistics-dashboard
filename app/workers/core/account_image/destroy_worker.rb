class Core::AccountImage::DestroyWorker
  
  include Sidekiq::Worker
  sidekiq_options :backtrace => true
  
  def perform(object_id)
    obj = Core::AccountImage.find(object_id)
    begin
      access_token = Nestful::Request.new(Constants::SOFTLAYER_OBJECT_STORAGE_SINGAPORE_URL,headers: {"X-Auth-User" => Constants::SOFTLAYER_USERID,"X-Auth-Key" => Constants::SOFTLAYER_API_KEY}).execute.headers["x-auth-token"]
      delete_thumb_command = "curl -i #{obj.thumb_url} -X DELETE -H \"X-Auth-Token: #{access_token}\""
      delete_dp_command = "curl -i #{obj.dp_url} -X DELETE -H \"X-Auth-Token: #{access_token}\""
      delete_original_command = "curl -i #{obj.original_url} -X DELETE -H \"X-Auth-Token: #{access_token}\""
      system(delete_thumb_command)
      system(delete_dp_command)
      system(delete_original_command)      
      obj.destroy
    rescue Exception => e
      obj.update_attributes(cdn_published_error: e.to_s)
    end
  end
end