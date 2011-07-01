require 'spec_helper'

describe "New Hangover Image" do
  include RequestHelpers
  include AmazonS3Helpers

  describe "Create a new hangover" do

    context "user is signed in" do
      SAMPLE_DISPLAY_NAME = "Mara"

      let(:user) { Factory(:user, :display_name => SAMPLE_DISPLAY_NAME) }

      before do
        sign_in(user)
        visit new_hangover_image_path
      end

      it_should_show_the_page_title(spec_translate(:new_hangover))

      context "Selecting a valid file then pressing '#{spec_translate(:next)}'" do

        before do
          attach_file(spec_translate(:image), image_fixture_path)
          upload_to_s3 spec_translate(:next)
        end

        # This test is here for a placeholder only. It does not actually check that
        # Amazon redirects me to /hangovers/new. This is difficult to check without
        # actually contacting Amazon. Even using FakeWeb you still know the desired
        # outcome before the test starts.

        it "should redirect the me to the new hangover page" do
          current_path.should == new_hangover_path
        end
      end

      context "pressing '#{spec_translate(:create_hangover)}' without selecting a file" do
        before { upload_to_s3 spec_translate(:next), :fail => true }

        # This test is here for a placeholder only. It does not actually check that
        # Amazon returns an error page

        it "should remain on the amazon s3 upload page" do
          current_url.should == ImageUploader.new.direct_fog_url
        end
      end

      context "Upload an invalid file" do
        before do
          attach_file(spec_translate(:image), image_fixture_path(:invalid => true))
          upload_to_s3 spec_translate(:next)
        end

        # Placeholder test
        it "should redirect the me to the new hangover page" do
          current_path.should == new_hangover_path
        end
      end
    end

    context "user is not signed in" do
      before do
        sign_out
        visit new_hangover_image_path
      end

      it "should take me to the sign in page" do
        current_path.should == new_user_session_path
      end

      it "should show me '#{spec_translate(:sign_up_or_sign_in_to_continue)}'" do
        page.should have_content spec_translate(:sign_up_or_sign_in_to_continue)
      end
    end
  end
end

