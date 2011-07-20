require 'spec_helper'
require 'carrierwave/test/matchers'

describe ImageUploader do
  include CarrierWave::Test::Matchers

  let(:hangover) { stub_model(Hangover).as_null_object }
  let(:uploader_for_image) { ImageUploader.new(hangover, :image) }

  describe ".store_dir" do
    context "'NightOut', :pic" do
      it "should return 'uploads/night_out/pic'" do
        subject.class.store_dir("NightOut", :pic).should == "uploads/night_out/pic"
      end
    end
  end

  describe ".key" do
    context ":store_dir => 'uploads/night_out/pic'" do
      let(:options) { {:store_dir => 'uploads/night_out/pic' } }

      it "should == uploads/night_out/pic/{guid}/${filename}'" do
        subject.class.key(
          options
        ).should =~ /^uploads\/night_out\/pic\/[\d\a-f\-]+\/\$\{filename\}$/
      end

    end

    context ":model_class =>'NightOut', :mounted_as => :pic" do
      let(:options) { {:model_class =>'NightOut', :mounted_as => :pic} }

      before { subject.class.stub(:store_dir).and_return("store_dir") }

      it 'should == #{store_dir(NightOut, :pic)}/{guid}/${filename}' do
        subject.class.key(
          options
        ).should =~ /^store_dir\/[\d\a-f\-]+\/\$\{filename\}$/
      end

      context ":as => :regexp" do
        include UploaderHelpers

        before {options.merge!(:as => :regexp)}

        it "should return a regexp" do
          subject.class.key(options).should be_a(Regexp)
        end

        context "a valid key" do
          let(:key) {
            sample_key(:subject => "NightOut", :mounted_as => :pic, :extension => "jpg")
          }

          let(:image_uploader) { mock("ImageUploader") }

          before {
            subject.class.stub(:new).and_return(image_uploader)
          }

          context "with a valid extension" do
            before { image_uploader.stub(:extension_white_list).and_return(["jpg"]) }

            it "should be matched by the returned regexp" do
              key.should =~ subject.class.key(options)
            end
          end

          context "with an invalid extension" do
            before { image_uploader.stub(:extension_white_list).and_return(["exe"]) }

            it "should not be matched by the returned regexp" do
              key.should_not =~ subject.class.key(options)
            end
          end
        end

        context "an invalid key" do
          let(:key) {
            sample_key(:invalid => true, :subject => "NightOut", :mounted_as => :pic)
          }

          it "should not be matched by the returned regexp" do
            key.should_not =~ subject.class.key(options)
          end
        end
      end
    end
  end

  describe "#extension_white_list" do
    it "should return 'jpg, jpeg, gif and png'" do
      subject.extension_white_list.should == %w(jpg jpeg gif png)
    end
  end

  it "should respond to #key=" do
    subject.should be_respond_to("key=")
  end

  it "should respond to #success_action_redirect=" do
    subject.should be_respond_to("success_action_redirect=")
  end

  it "should respond to #success_action_redirect" do
    subject.should be_respond_to(:success_action_redirect)
  end

  ImageUploader.fog_credentials.keys.each do |key|
    describe "##{key}" do
      it "should return the #{key.to_s.titleize}" do
        subject.send(key).should == ImageUploader.fog_credentials[key]
      end

      it "should not be nil" do
        subject.send(key).should_not be_nil
      end
    end
  end

  describe "#direct_fog_url" do
    it "should return the result from CarrierWave::Storage::Fog::File#public_url" do
      subject.direct_fog_url.should == CarrierWave::Storage::Fog::File.new(
        subject, nil, nil
      ).public_url
    end

    context ":with_path => true" do
      sample_path = "upload_dir/bliind.exe"
      context "#key is set to '#{sample_path}'" do
        before { subject.key = sample_path }

        it "should return the full url with '/#{sample_path}' as the path" do
          URI.parse(subject.direct_fog_url(:with_path => true)).path.should == "/#{sample_path}"
        end
      end
    end
  end

  describe "#persisted?" do
    it "should return false" do
      subject.should_not be_persisted
    end
  end

  describe "#key" do
    context "where the key is not set" do
      before { uploader_for_image.key = nil }

      it "should return the result of .key :store_dir => store_dir" do
        uploader_for_image.stub(:store_dir).and_return("store_dir")
        subject.class.stub(:key).with(:store_dir => "store_dir").and_return("maggot")
        uploader_for_image.key.should == "maggot"
      end
    end

    SAMPLE_KEY = "maggot"
    context "where the key is set to '#{SAMPLE_KEY}'" do

      before { uploader_for_image.key = SAMPLE_KEY }

      it "should return '#{SAMPLE_KEY}'" do
        uploader_for_image.key.should == SAMPLE_KEY
      end
    end
  end

  describe "#filename" do
    SAMPLE_KEY = "store_dir/guid/filename"

    context "#key is set to '#{SAMPLE_KEY}'" do
      before { subject.key = SAMPLE_KEY }

      filename = SAMPLE_KEY.split("/")
      filename.shift
      filename = filename.join("/")

      it "should return '#{filename}'" do
        subject.filename.should == filename
      end
    end

    context "#key is not set" do
      it "should return nil" do
        subject.filename.should be_nil
      end
    end

  end

  describe "#store_dir" do
    context "for a 'hangover' mounted as an 'image'" do

      it "should return the result from .store_dir Hangover :image" do
        subject.class.stub(:store_dir).with(Hangover, :image).and_return("store_dir")
        uploader_for_image.store_dir.should == "store_dir"
      end
    end
  end

  describe "#acl" do
    it "should return the sanitized s3 access policy" do
      subject.acl.should == subject.s3_access_policy.to_s.gsub("_", "-")
    end
  end

  describe "#success_action_redirect" do
    SAMPLE_URL = "http://example.com/some_url"

    context "where #success_action_redirect = '#{SAMPLE_URL}'" do

      before { subject.success_action_redirect = SAMPLE_URL }

      it "should return #{SAMPLE_URL}" do
        subject.success_action_redirect.should == SAMPLE_URL
      end
    end
  end

  # http://aws.amazon.com/articles/1434?_encoding=UTF8
  describe "#policy" do

    def decoded_policy(options = {})
      uploader = options.delete(:uploader) || subject
      JSON.parse(Base64.decode64(uploader.policy(options)))
    end

    it "should return Base64-encoded JSON" do
      decoded_policy.should be_a(Hash)
    end

    it "should not contain any new lines" do
      subject.policy.should_not include("\n")
    end

    context "expiration" do
      SAMPLE_EXPIRATION = 2.minutes

      def expiration(options = {})
        decoded_policy(options)["expiration"]
      end

      def have_expiration(expires_in = ImageUploader::DEFAULT_UPLOAD_EXPIRATION)
        eql(
          JSON.parse({
            "expiry" => expires_in.from_now.to_time
          }.to_json)["expiry"].to_time
        )
      end

      it "should be #{ImageUploader::DEFAULT_UPLOAD_EXPIRATION / 3600} hours from now" do
        Timecop.freeze(Time.now) do
          expiration.to_time.should have_expiration
        end
      end

      it "should be #{SAMPLE_EXPIRATION / 60 } minutes from now when passing {:expiration => #{SAMPLE_EXPIRATION}}" do
        Timecop.freeze(Time.now) do
          expiration(:expiration => SAMPLE_EXPIRATION).to_time.should have_expiration(SAMPLE_EXPIRATION)
        end
      end

    end

    context "conditions" do

      def conditions(options = {})
        decoded_policy(options)["conditions"]
      end

      def have_condition(field, value = nil)
        field.is_a?(Hash) ? include(field) : include(["starts-with", "$#{field}", value.to_s])
      end

      context "should include" do

        # Rails form builder conditions

        it "'utf8'" do
          conditions.should have_condition(:utf8)
        end

        # S3 conditions

        it "'key'" do
          uploader_for_image.key
          conditions(
            :uploader => uploader_for_image
          ).should have_condition(:key, uploader_for_image.store_dir)
        end

        it "'bucket'" do
          conditions.should have_condition("bucket" => subject.fog_directory)
        end

        it "'acl'" do
          conditions.should have_condition("acl" => subject.acl)
        end

        it "'success_action_redirect'" do
          subject.success_action_redirect = "http://example.com/some_url"
          conditions.should have_condition("success_action_redirect" => "http://example.com/some_url")
        end

        context "'content-length-range of'" do
          SAMPLE_MAX_FILE_SIZE = 10.megabytes

          def have_content_length_range(max_file_size = ImageUploader::DEFAULT_MAX_FILE_SIZE)
            include(["content-length-range", 1, max_file_size])
          end

          it "#{ImageUploader::DEFAULT_MAX_FILE_SIZE} bytes" do
            conditions.should have_content_length_range
          end

          it "#{SAMPLE_MAX_FILE_SIZE} bytes when passing {:max_file_size => #{SAMPLE_MAX_FILE_SIZE}}" do
            conditions(
              :max_file_size => SAMPLE_MAX_FILE_SIZE
            ).should have_content_length_range(SAMPLE_MAX_FILE_SIZE)
          end
        end
      end
    end
  end

  describe "#signature" do
    it "should not contain any new lines" do
      subject.signature.should_not include("\n")
    end

    it "should return a base64 encoded 'sha1' hash of the secret key and policy document" do
      Base64.decode64(subject.signature).should == OpenSSL::HMAC.digest(
        OpenSSL::Digest::Digest.new('sha1'),
        subject.aws_secret_access_key, subject.policy
      )
    end
  end

  describe "#image" do
    it "should return itself" do
      subject.image.should == subject
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

