# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base
  DEFAULT_UPLOAD_EXPIRATION = 10.hours
  DEFAULT_MAX_FILE_SIZE = 5.megabytes

  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :success_action_redirect
  attr_writer :key

  def direct_fog_url
    CarrierWave::Storage::Fog::File.new(self, nil, nil).public_url
  end

  def key
    @key ||= "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{UUID.generate}/${filename}"
  end

  self.fog_credentials.keys.each do |key|
    define_method(key) do
      fog_credentials[key]
    end
  end

  def image
    self
  end

  def persisted?
    false
  end

  def acl
    s3_access_policy.to_s.gsub('_', '-')
  end

  def policy(options = {})
    options[:expiration] ||= DEFAULT_UPLOAD_EXPIRATION
    options[:max_file_size] ||= DEFAULT_MAX_FILE_SIZE

    Base64.encode64(
      {
        'expiration' => options[:expiration].from_now,
        'conditions' => [
          ["starts-with", "$utf8", ""],
          ["starts-with", "$key", store_dir],
          {"bucket" => fog_directory},
          {"acl" => acl},
          {"success_action_redirect" => success_action_redirect},
          ["content-length-range", 1, options[:max_file_size]]
        ]
      }.to_json
    ).gsub("\n","")
  end

  def signature
    Base64.encode64(
      OpenSSL::HMAC.digest(
        OpenSSL::Digest::Digest.new('sha1'),
        aws_secret_access_key, policy
      )
    ).gsub("\n","")
  end


  # Include RMagick or ImageScience support:
  include CarrierWave::RMagick
  # include CarrierWave::ImageScience

  # Choose what kind of storage to use for this uploader:
  # storage :file
  storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    if @key
      key_path = @key.split("/")
      key_path.pop
      key_path.join("/")
    end
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  version :thumb do
    process :resize_to_limit => [200, 200]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def default_url
    "http://1.bp.blogspot.com/_ADom8ach2mM/TCDGVF8-yNI/AAAAAAAACfI/UswOeNAL4QQ/s1600/sober.jpg"
    #"/images/fallback/" + [version_name, "default.png"].compact.join('_')
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end

