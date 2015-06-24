class Core::GitToS3::UploadWorker
  
  include Sidekiq::Worker
  sidekiq_options :backtrace => true
  require 'fileutils'
  
  def perform(object_id)
    obj = Core::CustomDashboard.find(object_id)
    obj.update_attributes(cdn_status: "Step #2: Cloning..")
    new_count = obj.cdn_published_count.blank? ? 1 : (obj.cdn_published_count.to_i + 1)
    begin
      #GIT CLONE
      folder_name = "/tmp/#{obj.cdn_bucket}"
      #=======
      #Setting Up Permissions For Git & cloning the git folder
      ssh_private_key = obj.ssh_private_key
      File.open("#{ENV['HOME']}/.ssh/tmp_ssh_private_key", File::CREAT | File::RDWR, 0600) do |f|
        f.write(ssh_private_key)
        f.close
      end
      system("bash #{Rails.root}/bash_scripts/add_key.sh #{obj.git_url} #{obj.cdn_bucket}")
      #=======
      obj.update_attributes(cdn_status: "Step #3: Creating Bucket")

      #Upload to Softlyer
      #s3_url = "#{Constants::SOFTLAYER_ENDPOINT}/#{obj.cdn_bucket}"

      #Access Token
      #access_token = Nestful::Request.new(Constants::SOFTLAYER_OBJECT_STORAGE_SINGAPORE_URL,headers: {"X-Auth-User" => Constants::SOFTLAYER_USERID,"X-Auth-Key" => Constants::SOFTLAYER_API_KEY}).execute.headers["x-auth-token"]
      #Creating Object Storage Container
      #Nestful::Request.new(s3_url, headers: {"X-Auth-Token" => access_token}, method: :put).execute

      #Configure Static Website

      #UPLOAD TO S3
      s3 = Constants::S3
      bucket = s3.buckets[obj.cdn_bucket]
      if bucket.exists?
        bucket.clear!
      else
        bucket = s3.buckets.create(obj.cdn_bucket, :acl => :public_read)
      end
      bucket.configure_website do |cfg|
        cfg.index_document_suffix = 'index.html'
      end
      s3_url = "http://#{obj.cdn_bucket}.s3-website-ap-southeast-1.amazonaws.com"
      folder_to_delete = folder_name

      Core::GitToS3::UploadWorker.recursive_loop_on_folder_for_s3(bucket, "", folder_name)

      #Core::GitToS3::UploadWorker.recursive_loop_on_folder_for_object_storage(s3_url, "", folder_name, access_token)
      #Nestful::Request.new(s3_url, headers: {"X-Auth-Token" => access_token,  "X-Container-Read" => ".r:*","X-Container-Meta-Web-Index" => "index.html", "X-Container-Meta-Web-Error" => "error.html", "X-Storage-URL" => s3_url}, method: :post).execute

      obj.update_attributes(cdn_status: "Step #4: Uploading")
      obj.update_attributes(cdn_published_at: Time.now, cdn_published_url: s3_url, cdn_published_error: "", cdn_published_count: new_count, cdn_status: "Deployed.")
    rescue Exception => e
      obj.update_attributes(cdn_published_error: e.to_s, cdn_published_count: new_count, cdn_status: "Failed.")
    end
    #======
    #Removing file from public
    #======
    begin
      system("rm #{ENV['HOME']}/.ssh/tmp_ssh_private_key && rm -rf #{folder_to_delete}")
    rescue Exception => e

    end
  end
  
  def self.recursive_loop_on_folder_for_s3(bucket, prev_folder_name, folder_name)
    valid_extensions = Constants::CUSTOM_DASHBOARD_ALLOWED_FILETYPES
    Dir.foreach(folder_name) do |f|
      next if folder_name.include? "node_modules" or f.include? "grunt"
      path = folder_name + "/" + f
      file_name = prev_folder_name != "" ? prev_folder_name + "/" + f : f
      if File.file? path
        v = f.split(".").last
        if v.present? and valid_extensions.include? v
          File.chmod(775,path)
          bucket.objects[file_name].write(file: path)
          bucket.objects[file_name].acl = :public_read
        end
        File.delete(path)
      elsif File.directory? path
        if f.index(".").blank?
          Core::GitToS3::UploadWorker.recursive_loop_on_folder_for_s3(bucket, file_name, path)
        end
      end
    end
  end
  

  # def self.recursive_loop_on_folder_for_object_storage(object_storage_container_path, prev_folder_name, folder_name, access_token)
  #   valid_extensions = ["png", "jpeg", "jpg", "csv", "js", "json", "css", "html", "gif"]
  #   Dir.foreach(folder_name) do |f|
  #     next if folder_name.include? "node_modules" or f.include? "grunt"
  #     path = folder_name + "/" + f
  #     file_name = prev_folder_name != "" ? prev_folder_name + "/" + f : f
  #     if File.file? path
  #       v = f.split(".").last
  #       if v.present? and valid_extensions.include? v
  #         upload_command = "curl -i -XPUT -H \"X-Auth-Token: #{access_token}\" -H \"X-Storage-URL: #{object_storage_container_path}/#{file_name}\" --data-binary @#{path} #{object_storage_container_path}/#{file_name} "
  #         puts upload_command
  #         system(upload_command)
  #       end
  #       File.delete(path)
  #     elsif File.directory? path
  #       if f.index(".").blank?
  #         Core::GitToS3::UploadWorker.recursive_loop_on_folder_for_object_storage(object_storage_container_path, file_name, path,access_token)
  #       end
  #     end
  #   end
  # end

end