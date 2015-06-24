# encoding: utf-8

class ImageUrlUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick
  storage :file

  def store_dir
    "/tmp/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
  # Create different versions of your uploaded files:
  version :thumb do
    process :resize_to_fit => [25, 25]
  end

  version :dp do
    process :resize_to_fit => [150, 150]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
