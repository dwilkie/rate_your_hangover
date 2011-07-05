module UploaderHelpers
  def sample_key(options = {})
    options[:valid] = true unless options[:valid] == false
    options[:valid] &&= !options[:invalid]
    options[:base] ||= ImageUploader.new(options[:subject], :image).key
    key = options[:base].split("/")
    key.pop
    key.shift unless options[:valid]
    key << "off_me_guts.jpg"
    key.join("/")
  end
end

