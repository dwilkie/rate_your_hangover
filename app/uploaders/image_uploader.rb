# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base
  DEFAULT_UPLOAD_EXPIRATION = 10.hours
  DEFAULT_MAX_FILE_SIZE = 5.megabytes

  S3_FILENAME_WILDCARD = "${filename}"

  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :success_action_redirect, :remote_net_url
  attr_writer :key

  def self.store_dir(model_class, mounted_as)
    "uploads/#{model_class.to_s.underscore}/#{mounted_as}"
  end

  def self.allowed_file_types(options = {})
    file_types = %w(jpg jpeg gif png)
    if options[:as] == :sentence
      file_types.to_sentence
    elsif options[:as] == :regexp_string
      "\\.(#{file_types.join("|")})"
    else
      file_types
    end
  end

  def self.key(options = {})
    options[:store_dir] ||= store_dir(options[:model_class], options[:mounted_as])
    options[:guid] ||= UUID.generate
    options[:filename] ||= S3_FILENAME_WILDCARD
    key_path = "#{options[:store_dir]}/#{options[:guid]}/#{options[:filename]}"
    if options[:as] == :regexp
      key_parts = key_path.split("/")
      key_parts.pop
      key_parts.pop
      key_path = key_parts.join("/")
      key_path = /\A#{key_path}\/[a-f\d\-]+\/.+#{allowed_file_types(:as => :regexp_string)}\z/
    end
    key_path
  end

  def direct_fog_url(options = {})
    fog_uri = CarrierWave::Storage::Fog::File.new(self, nil, nil).public_url
    if options[:with_path]
      uri = URI.parse(fog_uri)
      path = "/#{key}"
      uri.path = path
      fog_uri = uri.to_s
    end
    fog_uri
  end

  def key(fname = nil)
    @key ||= self.class.key(:store_dir => store_dir, :filename => fname)
  end

  def has_key?
    @key.present? && !(@key =~ /#{Regexp.escape(S3_FILENAME_WILDCARD)}\z/)
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
    unless has_key?
      # Use the attached models remote url to generate a new key otherwise raise an error
      remote_url = model.send("remote_#{mounted_as}_url")
      remote_url ? key(remote_url.split("/").pop) : raise(
        ArgumentError,
        "could not generate filename because the uploader has no key and the #{model.class} has no remote_#{mounted_as}_url"
      )
    end


    # Update the versions to use this key
    # This is imperiative otherwise a new guid will be generated for each version
    versions.each do |name, uploader|
      uploader.key = key
    end

    key_path = key.split("/")
    filename_parts = []
    filename_parts.unshift(key_path.pop)
    filename_parts.unshift(key_path.pop)
    File.join(filename_parts)
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Create different versions of your uploaded files:
  version :thumb do
    process :resize_to_limit => [200, 200]

    def full_filename(for_file)
      extname = File.extname(for_file)
      [for_file.chomp(extname), version_name].compact.join('_') << extname
    end
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    self.class.allowed_file_types
  end
end

