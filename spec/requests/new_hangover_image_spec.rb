require 'spec_helper'

describe "New Hangover Image" do
  include RequestHelpers

  describe "GET /hangover_images/new" do

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
          click_button spec_translate(:next)
        end

        it "should redirect the me to the new hangover page" do
          current_path.should == new_hangover_path
        end
      end

      context "pressing '#{spec_translate(:create_hangover)}' selecting a file" do
        before { click_button spec_translate(:create_hangover) }

        context "within" do
          it_should_display_errors_for(:hangover, :image, :cant_be_blank)
        end
      end

      context "try to upload an invalid file" do
        before do
          attach_file(spec_translate(:image), image_fixture_path(:invalid => true))
          click_button spec_translate(:create_hangover)
        end

        context "within" do
          it_should_display_errors_for(:hangover, :image, :invalid_file_type)
        end
      end
    end

    context "user is not signed in" do
      before do
        sign_out
        visit new_hangover_path
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

