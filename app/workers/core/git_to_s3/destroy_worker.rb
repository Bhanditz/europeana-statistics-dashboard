class Core::GitToS3::DestroyWorker
  
  include Sidekiq::Worker
  sidekiq_options :backtrace => true
  
  def perform(cdn_bucket)
    begin
      #Softlayer Object Storage

      # softlayer_object_url = "#{Constants::SOFTLAYER_ENDPOINT}/#{cdn_bucket}"

      # access_token = Nestful::Request.new(Constants::SOFTLAYER_OBJECT_STORAGE_SINGAPORE_URL,headers: {"X-Auth-User" => Constants::SOFTLAYER_USERID,"X-Auth-Key" => Constants::SOFTLAYER_API_KEY}).execute.headers["x-auth-token"]

      # we need to empty the container before deleting

      # container_objects = Nestful::Request.new("#{softlayer_object_url}",method: :get, headers: {"X-Auth-Token" => access_token}).execute.body.split("\n")
      # container_objects.each do |container_object|
      #   delete_object_command = "curl -i #{softlayer_object_url}/#{container_object} -X DELETE -H \"X-Auth-Token: #{access_token}\""
      #   system(delete_object_command)
      # end

      # delete_command = "curl -i #{softlayer_object_url} -X DELETE -H \"X-Auth-Token: #{access_token}\""
      # system(delete_command)

      #Amazon S3 code
      s3 = Constants::S3
      bucket = s3.buckets[cdn_bucket]
      if bucket.exists?
        bucket.clear!
        bucket.delete
      end
    rescue Exception => e
    end
  end
  
end