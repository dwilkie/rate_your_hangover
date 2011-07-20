# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base
  DEFAULT_UPLOAD_EXPIRATION = 10.hours
  DEFAULT_MAX_FILE_SIZE = 5.megabytes

  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :success_action_redirect
  attr_writer :key

  def self.store_dir(model_class, mounted_as)
    "uploads/#{model_class.to_s.underscore}/#{mounted_as}"
  end

  def self.key(options = {})
    options[:store_dir] ||= store_dir(options[:model_class], options[:mounted_as])
    key_path = "#{options[:store_dir]}/#{UUID.generate}/${filename}"
    if options[:as] == :regexp
      key_parts = key_path.split("/")
      key_parts.pop
      key_parts.pop
      key_path = key_parts.join("/")
      uploader_instance = self.new
      key_path = /\A#{key_path}\/[a-f\d\-]+\/.+\.(#{uploader_instance.extension_white_list.join("|")})\z/
    end
    key_path
  end

  def direct_fog_url(path = nil)
    fog_uri = CarrierWave::Storage::Fog::File.new(self, nil, nil).public_url
    if path
      uri = URI.parse(fog_uri)
      path = "/#{path}" unless path[0] == "/"
      uri.path = path
      fog_uri = uri.to_s
    end
    fog_uri
  end

  def key
    @key ||= self.class.key(:store_dir => store_dir)
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
    self.class.store_dir(model.class, mounted_as)
  end

  def filename
    if @key
      key_path = @key.split("/")
      filename_parts = []
      filename_parts.unshift(key_path.pop)
      filename_parts.unshift(key_path.pop)
      File.join(filename_parts)
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

