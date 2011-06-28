require 'spec_helper'

describe HangoverImagesController do

  describe "GET /hangovers/new" do

    let(:image_uploader) { mock_model(ImageUploader).as_null_object.as_new_record }
    let(:hangover) { mock_model(Hangover).as_null_object.as_new_record }

    def do_new
      get :new
    end

    context "user is signed in" do
      before do
  #     sign_in current_user
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

      it "should assign '@image_uploader'" do
        do_new
        assigns[:image_uploader].should == image_uploader
      end
    end

#    context "user is not signed in" do
#      it "should redirect the user to the sign in path" do
#        do_new
#        response.should redirect_to(new_user_session_path)
#      end
#    end

  end

end

