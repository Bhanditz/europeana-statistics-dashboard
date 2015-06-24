class Core::MapFile::UploadWorker
  
  include Sidekiq::Worker
  sidekiq_options :backtrace => true
  
  def perform(object_id, tmp_file,extention)
    obj = Core::MapFile.find(object_id)
    tmp_path =  "/tmp/#{obj.name.parameterize("_")}"
    system("cp #{tmp_file} #{tmp_path}")

    puts "#{Constants::SOFTLAYER_ENDPOINT}/#{SOFTLAYER_CONTAINER_NAME}/maps/#{obj.account.slug}/#{obj.name}.#{extention}"
    begin
      File.chmod(777,tmp_path)
      access_token = Nestful::Request.new(Constants::SOFTLAYER_OBJECT_STORAGE_SINGAPORE_URL,headers: {"X-Auth-User" => Constants::SOFTLAYER_USERID,"X-Auth-Key" => Constants::SOFTLAYER_API_KEY}).execute.headers["x-auth-token"]
      s3_url = "#{Constants::SOFTLAYER_ENDPOINT}/#{SOFTLAYER_CONTAINER_NAME}/maps/#{obj.account.slug}/#{obj.name.parameterize("_")}-#{SecureRandom.hex(3)}.#{extention}"
      upload_command = "curl -i -XPUT -H \"X-Auth-Token: #{access_token}\" --data-binary @#{tmp_path} #{s3_url}"
      system(upload_command)
      CoreMailer.map_file_uploaded(obj.account.slug,obj.name) if Rails.env.production?
      obj.update_attributes({cdn_published_url: s3_url,cdn_published_at: Time.now,cdn_published_count: ((obj.cdn_published_count || 0) +1)})
    rescue Exception => e
      obj.update_attributes({cdn_published_error: e.to_s})
    end
    File.delete(tmp_path)
  end
  
end