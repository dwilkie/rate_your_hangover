module UploaderHelpers
  def hangover_image_selector(version, remote_url = nil)

    # get an invalid sample key i.e. without the GUID
    sample_upload_key = sample_key(:subject => Hangover, :valid => false)
    key_parts = sample_upload_key.split("/")

    fog_url = ImageUploader.new.direct_fog_url

    # pop the filename off so we are left with the invalid upload dir
    filename = key_parts.pop

    remote_url ||= filename
    original_filename = File.basename(remote_url)

    upload_dir = key_parts.join("/")
    extname = File.extname(original_filename)

    # generate to version filename from the version
    version_filename = [original_filename.chomp(extname), version].compact.join('_') << extname
    ".//img[contains(@src, '#{version_filename}') and contains(@src, '#{fog_url}') and contains(@src, '#{upload_dir}')]"
  end

  def sample_key(options = {})
    options[:valid] = true unless options[:valid] == false
    options[:valid] &&= !options[:invalid]
    options[:mounted_as] ||= :image
    options[:base] ||= ImageUploader.key(:model_class => options[:subject], :mounted_as => options[:mounted_as])
    if options[:filename]
      filename_parts = options[:filename].split(".")
      options[:extension] = filename_parts.pop if filename_parts.size > 1
      options[:filename] = filename_parts.join(".")
    end
    options[:filename] ||= "off_me_guts"
    options[:extension] = options[:extension] ? options[:extension].gsub(".", "") : "jpg"
    key = options[:base].split("/")
    key.pop
    key.pop unless options[:valid]
    key << "#{options[:filename]}.#{options[:extension]}"
    key.join("/")
  end
end

