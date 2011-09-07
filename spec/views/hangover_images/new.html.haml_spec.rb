require 'spec_helper'

describe "hangover_images/new.html.haml" do
  include HangoverExampleHelpers

  let(:image_uploader) {
    stub_model(
      ImageUploader,
      :mounted_as => :image # so simple form renders a file field
    ).as_null_object.as_new_record
  }

  let(:parent_selector) { [] }

  before do
    # so simple form renders a file field
    image_uploader.stub(:image).and_return(image_uploader)
    assign(:image_uploader, image_uploader)
  end

  it_should_set_the_title(:to => spec_translate(:new_hangover))

  it "should show a link to '#{spec_translate(:upload_from_url)}'" do
    render
    rendered.should have_selector(
      "a[@href='/hangovers/new']", :text => spec_translate(:upload_from_url)
    )
  end

  context "form" do
    it_should_have_button(:text => spec_translate(:next))
  end
end

