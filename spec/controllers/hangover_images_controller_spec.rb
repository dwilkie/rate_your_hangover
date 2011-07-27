require 'spec_helper'

describe HangoverImagesController do

  describe "GET /hangovers/new" do

    let(:image_uploader) { mock_model(ImageUploader).as_null_object.as_new_record }
    let(:hangover) { mock_model(Hangover).as_null_object.as_new_record }
    let(:current_user) { Factory(:user) }

    def do_new
      get :new
    end

    context "user is signed in" do
      before do
        sign_in current_user
        ImageUploader.stub(:new).and_return(image_uploader)
        Hangover.stub(:new).and_return(hangover)
      end

      it "should render the new template" do
        do_new
        response.should render_template(:new)
      end

      it "should build a new image uploader for the hangover" do
        ImageUploader.should_receive(:new).with(hangover, :image)
        do_new
      end

      it "should set the redirect url to the new hangover url" do
        image_uploader.should_receive("success_action_redirect=").with(new_hangover_url)
        do_new
      end

      it "should assign '@image_uploader'" do
        do_new
        assigns[:image_uploader].should == image_uploader
      end
    end

    it_should_behave_like "an action which requires authentication" do
      let(:action) { :do_new }
    end

  end

end

