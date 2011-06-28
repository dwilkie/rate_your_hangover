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
      subject.persisted?.should be_false
    end
  end

  describe "#key" do
    it "should return 'uploads/hangover/image/{guid}/${filename}'" do
      uploader_for_image.key.should =~ /^uploads\/hangover\/image\/[\d\w\-]+\/\$\{filename\}$/
    end
  end

  describe "#acl" do
    it "should return the sanitized s3 access policy" do
      subject.acl.should == subject.s3_access_policy.to_s.gsub("_", "-")
    end
  end

  # http://aws.amazon.com/articles/1434?_encoding=UTF8
  describe "#policy" do
    def decoded_policy
      JSON.parse(Base64.decode64(subject.policy))
    end

    it "should return Base64-encoded JSON" do
      decoded_policy.should be_a(Hash)
    end

    it "should not contain any new lines" do
      subject.policy.should_not include("\n")
    end

      context "expiration" do

      it "should be #{ImageUploader::DEFAULT_UPLOAD_EXPIRATION / 3600} hours from now" do
        Timecop.freeze(Time.now) do
          decoded_policy["expiration"].to_time.should == JSON.parse({
            "expiry" => ImageUploader::DEFAULT_UPLOAD_EXPIRATION.from_now.to_time
          }.to_json)["expiry"].to_time
        end
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

