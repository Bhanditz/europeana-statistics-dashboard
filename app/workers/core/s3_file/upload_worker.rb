class Core::S3File::UploadWorker
  
  include Sidekiq::Worker
  sidekiq_options :backtrace => true
  
  def perform(object_type, object_id,api_token)
    s = "/tmp/#{SecureRandom.hex(24)}.csv"
    if object_type == "DataStore"
      obj = Core::DataStore.find(object_id)
      obj.generate_file_in_tmp(s,api_token)
    elsif object_type == "ConfigurationEditor"
      obj = Core::ConfigurationEditor.find(object_id)
      obj.generate_file_in_tmp(s)
    end
    new_count = obj.cdn_published_count.blank? ? 1 : (obj.cdn_published_count.to_i + 1)
    begin
      File.chmod(777,s)
      if obj.core_project.cdn_source == "s3"
        #Amazon S3 code
        s3 = Constants::S3
        s3.buckets[Constants::AMAZON_S3_BUCKET].objects[obj.s3_file_name].write(file: s)
        s3.buckets[Constants::AMAZON_S3_BUCKET].objects[obj.s3_file_name].acl = :public_read
        s3_url = s3.buckets[Constants::AMAZON_S3_BUCKET].objects[obj.s3_file_name].public_url.to_s
      else
        #SOFTLAYER OBJECT STORAGE CODE
        access_token = Nestful::Request.new(Constants::SOFTLAYER_OBJECT_STORAGE_SINGAPORE_URL,headers: {"X-Auth-User" => Constants::SOFTLAYER_USERID,"X-Auth-Key" => Constants::SOFTLAYER_API_KEY}).execute.headers["x-auth-token"]
        s3_url = "#{Constants::SOFTLAYER_ENDPOINT}/#{SOFTLAYER_CONTAINER_NAME}/#{obj.s3_file_name}"
        upload_command = "curl -i -XPUT -H \"X-Auth-Token: #{access_token}\" --data-binary @#{s} #{s3_url}"
        system(upload_command)
      end
      obj.update_attributes(cdn_published_at: Time.now, cdn_published_url: s3_url, cdn_published_error: "", cdn_published_count: new_count)
    rescue Exception => e
      obj.update_attributes(cdn_published_error: e.to_s, cdn_published_count: new_count)
    end
    File.delete(s)
  end
  
end