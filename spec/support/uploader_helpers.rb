module UploaderHelpers
  def sample_key(options = {})
    options[:valid] = true unless options[:valid] == false
    options[:valid] &&= !options[:invalid]
    options[:mounted_as] ||= :image
    options[:base] ||= ImageUploader.key(:model_class => options[:subject], :mounted_as => options[:mounted_as])
    if options[:filename]
      filename_parts = options[:filename].split(".")
      options[:extension] = filename_parts.pop if filename_parts.size > 1
      options[:filename] = options[:filename].join(".")
    end
    options[:filename] ||= "off_me_guts"
    options[:extension] = options[:extension] ? options[:extension].gsub(".", "") : "jpg"
    key = options[:base].split("/")
    key.pop
    key.shift unless options[:valid]
    key << "#{options[:filename]}.#{options[:extension]}"
    key.join("/")
  end
end

