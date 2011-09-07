module AmazonS3Helpers
  include CarrierWaveDirect::Test::CapybaraHelpers

  def upload_directly(button_locator, options = {})
    FakeWeb.clean_registry

    image_uploader = ImageUploader.new

    if options[:process_image]
      # attempt to process the image

      upload_path = find_upload_path

      options.merge!(:redirect_key => sample_key(:base => find_key, :filename => File.basename(upload_path)))

      image_uploader.key = options[:redirect_key]
      download_url = image_uploader.direct_fog_url(:with_path => true)

      # Register the download url and return the uploaded file in the body
      FakeWeb.register_uri(:get, download_url, :body => File.open(upload_path))
    end

    super(image_uploader, button_locator, options)
  end
end

