module UploaderHelpers
  include CarrierWaveDirect::Test::Helpers

  def hangover_image_selector(version, remote_url = nil)

    # get an invalid sample key i.e. without the GUID
    sample_upload_key = sample_key(:valid => false)
    key_parts = sample_upload_key.split("/")

    fog_url = ImageUploader.new.direct_fog_url

    # pop the filename off so we are left with the invalid upload dir
    key_parts.pop

    remote_url ||= image_fixture_path
    original_filename = File.basename(remote_url)

    upload_dir = key_parts.join("/")
    extname = File.extname(original_filename)

    # generate to version filename from the version
    version_filename = [original_filename.chomp(extname), version].compact.join('_') << extname
    ".//img[contains(@src, '#{version_filename}') and contains(@src, '#{fog_url}') and contains(@src, '#{upload_dir}')]"
  end

  def sample_key(options = {})
    super(Hangover.new.image, options)
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def url_scheme_white_list
    %w(http https)
  end

end

