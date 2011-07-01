require 'spec_helper'

def key_name(input)
  if input.is_a?(Hash)
    key = input.keys.first
    name = input[key]
  else
    key = name = input
  end
  [key, name]
end

describe "hangover_images/new.html.haml" do
  include HangoverExampleHelpers

  SAMPLE_FOG_URL = "https://bucket.example.com"

  let(:image_uploader) {
    stub_model(
      ImageUploader,
      :mounted_as => :image, # so simple form renders a file field
      :direct_fog_url => SAMPLE_FOG_URL
    ).as_null_object.as_new_record
  }

  let(:parent_selector) { [] }

  hidden_fields = [:key, {:aws_access_key_id => "AWSAccessKeyId"},
            :acl, :success_action_redirect, :policy, :signature]

  hidden_fields.each do |input|
    key, name = key_name(input)
    before do
      image_uploader.stub(key).and_return(key.to_s)
    end
  end

  before do
    # so simple form renders a file field
    image_uploader.stub(:image).and_return(image_uploader)
    assign(:image_uploader, image_uploader)
  end

  it_should_set_the_title(:to => spec_translate(:new_hangover))

  context "form" do

    it_should_submit_to(
      :action => SAMPLE_FOG_URL,
      :method => "post",
      :enctype => "multipart/form-data"
    )

    it_should_have_button(:text => spec_translate(:next))

    context "div" do
      before { parent_selector << "div" }

      context "inputs" do
        before { render }

        it_should_have_input(:image_uploader, :image, :type => :file, :name => :file)

        # this test is for documentation only.
        # the authenticity_token field is not rendered regardless in the test environment
        it "should not have an input for 'authenticity_token'" do
          parent_selector << "input[@name='authenticity_token']"
          rendered.should_not have_parent_selector
        end
      end
    end

    # http://aws.amazon.com/articles/1434?_encoding=UTF8
    context "amazon s3 hidden fields" do

      before { render }

      hidden_fields.each do |input|
        key, name = key_name(input)
        it_should_have_input(
          :image_uploader, key, :type => :hidden,
          :name => name, :value => key, :required => false
        )
      end
    end
  end
end

