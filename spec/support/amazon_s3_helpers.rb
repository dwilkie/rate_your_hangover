module AmazonS3Helpers
  def upload_to_s3(button_text, options = {})
    options[:success] = true unless options[:success] == false
    options[:success] &&= !options[:fail]

    if options[:success]
      redirect_url = URI.parse(page.find("input[@name='success_action_redirect']").value)
      key = page.find("input[@name='key']").value
      image_path = page.find("input[@name='file']").value
      sample_key = UploaderHelpers.sample_key(:base => key)
      redirect_url.query = Rack::Utils.build_nested_query({
        :bucket => ImageUploader.fog_directory,
        :key => sample_key,
        :etag => "\"d41d8cd98f00b204e9800998ecf8427\""
      })
      FakeWeb.clean_registry
      if options[:process_image]
        image_uploader = ImageUploader.new
        image_uploader.key = sample_key
        download_url = image_uploader.direct_fog_url(:with_path => true)
        FakeWeb.register_uri(:get, download_url, :body => File.open(image_path))
      end
      click_button button_text
      visit redirect_url.to_s
    else
      click_button button_text
    end
  end
end

