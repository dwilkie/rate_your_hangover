require 'carrierwave/test/matchers'

describe ImageUploader do
  include CarrierWave::Test::Matchers

  let(:hangover) { stub_model(Hangover).as_null_object }
  let(:uploader_for_image) { ImageUploader.new(hangover, :image) }

  it "should respond to #success_action_redirect" do
    subject.should be_respond_to(:success_action_redirect)
  end

  ImageUploader.fog_credentials.keys.each do |key|
    describe "##{key}" do
      it "should return the #{key.to_s.titleize}" do
        subject.send(key).should == ImageUploader.fog_credentials[key]
      end
    end
  end

  describe "#direct_fog_url" do
    it "should return the result from CarrierWave::Storage::Fog::File#public_url" do
      subject.direct_fog_url.should == CarrierWave::Storage::Fog::File.new(
        subject, nil, nil
      ).public_url
    end
  end

  describe "#persisted?" do
    it "should return false" do
      subject.should_not be_persisted
    end
  end

  describe "#store_key" do
    it "should return a guid" do
      subject.store_key.should =~ /^[\d\w\-]+$/
    end

    it "should be the same guid for the same object" do
      subject.store_key.should == subject.store_key
    end
  end

  describe "#store_dir" do
    context "a store key has been generated" do
      uploader_for_image.store_key

    end

    it "should return 'uploads/hangover/image/{guid}" do
      uploader_for_image.store_dir.should =~ /^uploads\/hangover\/image\/#{uploader_for_image.store_key}$/
    end
  end

  describe "#key" do
    it "should return {store_dir}/${filename}" do
      uploader_for_image.key.should =~ /^#{uploader_for_image.store_dir}\/\$\{filename\}$/
    end
  end

  describe "#acl" do
    it "should return the sanitized s3 access policy" do
      subject.acl.should == subject.s3_access_policy.to_s.gsub("_", "-")
    end
  end

  # http://aws.amazon.com/articles/1434?_encoding=UTF8
  describe "#policy" do
    def decoded_policy(uploader = nil)
      uploader ||= subject
      JSON.parse(Base64.decode64(uploader.policy))
    end

    it "should return Base64-encoded JSON" do
      decoded_policy.should be_a(Hash)
    end

    it "should not contain any new lines" do
      subject.policy.should_not include("\n")
    end

    context "expiration" do

      let(:expiration) { decoded_policy["expiration"] }

      it "should be #{ImageUploader::DEFAULT_UPLOAD_EXPIRATION / 3600} hours from now" do
        Timecop.freeze(Time.now) do
          expiration.to_time.should == JSON.parse({
            "expiry" => ImageUploader::DEFAULT_UPLOAD_EXPIRATION.from_now.to_time
          }.to_json)["expiry"].to_time
        end
      end
    end

    context "conditions" do

      let(:conditions) { decoded_policy["conditions"] }

      # Rails form builder conditions

      it "should have a utf8" do
        conditions.should include(["starts-with", "$utf8", ""])
      end

      it "should have an authenticity token" do
        conditions.should include(["starts-with", "$authenticity_token", ""])
      end

      it "should have a key" do
        decoded_policy(uploader_for_image)["conditions"].should include(["starts-with", "$key", uploader_for_image.store_dir])
      end

    end


  end

#  before do
#    uploader.store!(File.open(image_fixture_path))
#  end

#  context 'the thumb version' do
#    it "should scale down a landscape image to fit within 200 by 200 pixels" do
#      uploader.thumb.should be_no_larger_than(200, 200)
#    end
#  end
end

