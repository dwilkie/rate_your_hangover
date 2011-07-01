module AmazonS3Helpers
  def upload_to_s3(button_text, options = {})
    options[:success] ||= true
    options[:success] &&= !options[:fail]

    if options[:success]
      bucket = ImageUploader.fog_directory
      redirect_url = URI.parse(page.find("input[@name='success_action_redirect']").value)
      key = page.find("input[@name='key']").value.split("/")
      key.pop
      key = key.join("/eee5dfa0-85dd-012e-46f8-001eecc7a847/")
      redirect_url.query = Rack::Utils.build_nested_query({
        :bucket => bucket,
        :key => key,
        :etag => "\"d41d8cd98f00b204e9800998ecf8427\""
      })
      click_button button_text
      visit redirect_url.to_s
    else
      click_button button_text
    end
  end
end

