require 'spec_helper'
require 'carrierwave/test/matchers'

describe ImageUploader do
  include CarrierWave::Test::Matchers
  include UploaderHelpers

  describe "#extension_white_list" do
    it "should return #{extension_white_list}" do
      subject.extension_white_list.should == extension_white_list
    end
  end

  describe "#url_scheme_white_list" do
    it "should return #{url_scheme_white_list}" do
      subject.url_scheme_white_list.should == url_scheme_white_list
    end
  end

  pending "add some more uploader specific tests here..."
end

