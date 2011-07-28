module AmazonS3Helpers
  def upload_to_s3(button_text, options = {})
    options[:success] = true unless options[:success] == false
    options[:success] &&= !options[:fail]

    if options[:success]
      # simulate the upload to S3 being successful

      # form's success action redirect url
      redirect_url = URI.parse(page.find("input[@name='success_action_redirect']").value)

      # form's key
      key = page.find("input[@name='key']").value

      # path of the file to upload
      upload_path = page.find("input[@name='file']").value

      # clear all registered urls
      FakeWeb.clean_registry

      if options[:process_image]
        # attempt to process the image

        # build a sample key from the key in the form ignoring the upload path
        # i.e. simulate a valid file extension upload
        sample_key = UploaderHelpers.sample_key(:base => key)

        image_uploader = ImageUploader.new
        image_uploader.key = sample_key
        download_url = image_uploader.direct_fog_url(:with_path => true)

        # Register the download url and return the uploaded file in the body
        FakeWeb.register_uri(:get, download_url, :body => File.open(upload_path))
      else
        # do not process the image

        # build a key from the key in the form and the upload file path
        # e.g. to simulate an invalid file extension upload
        sample_key = UploaderHelpers.sample_key(:base => key, :filename => File.basename(upload_path))
      end

      redirect_url.query = Rack::Utils.build_nested_query({
        :bucket => ImageUploader.fog_directory,
        :key => sample_key,
        :etag => "\"d41d8cd98f00b204e9800998ecf8427\""
      })

      # click the button
      click_button button_text

      # simulate success redirect
      visit redirect_url.to_s
    else
      # simulate an unsuccessful s3 upload

      # click the button
      click_button button_text
    end
  end
end

