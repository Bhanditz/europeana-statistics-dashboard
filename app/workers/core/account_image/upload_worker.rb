class Core::AccountImage::UploadWorker
  
  include Sidekiq::Worker
  sidekiq_options :backtrace => true
  
  def perform(object_id)
    obj = Core::AccountImage.find(object_id)
    tmp_thumb_path = obj.image_url.thumb.path
    extension = obj.image_url.content_type.split("/")[-1]
    base_url = "#{Constants::SOFTLAYER_ENDPOINT}/#{SOFTLAYER_CONTAINER_NAME}/#{obj.account.slug}/logos/#{obj.account.slug}"
    thumb_url = "#{base_url}_thumb.#{extension}"
    tmp_dp_path = obj.image_url.dp.path
    dp_url  = "#{base_url}_dp.#{extension}"
    original_image_path = obj.image_url.path
    original_image_url = "#{base_url}_original.#{extension}"
    begin
      File.chmod(777,tmp_thumb_path,tmp_dp_path,original_image_path)
      access_token = Nestful::Request.new(Constants::SOFTLAYER_OBJECT_STORAGE_SINGAPORE_URL,headers: {"X-Auth-User" => Constants::SOFTLAYER_USERID,"X-Auth-Key" => Constants::SOFTLAYER_API_KEY}).execute.headers["x-auth-token"]
      upload_command_for_thumb = "curl -i -XPUT -H \"X-Auth-Token: #{access_token}\" --data-binary @#{tmp_thumb_path} #{thumb_url}"
      upload_command_for_dp = "curl -i -XPUT -H \"X-Auth-Token: #{access_token}\" --data-binary @#{tmp_dp_path} #{dp_url}"
      upload_command_for_original = "curl -i -XPUT -H \"X-Auth-Token: #{access_token}\" --data-binary @#{tmp_dp_path} #{original_image_url}"
      system(upload_command_for_thumb)
      system(upload_command_for_dp)
      system(upload_command_for_original)
      obj.base_url = base_url
      obj.filetype = extension
      obj.save!
      File.delete(tmp_thumb_path)
      File.delete(tmp_dp_path)
      File.delete(original_image_path)
    rescue Exception => e
      puts e.to_s
    end
  end
end