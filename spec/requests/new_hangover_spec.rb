require 'spec_helper'

describe "New Hangover" do
  include RequestHelpers

  describe "GET /hangovers/new" do

    before { visit new_hangover_path }

    context "user is signed in" do
      SAMPLE_DISPLAY_NAME = "Mara"

      let(:user) { Factory(:user, :display_name => SAMPLE_DISPLAY_NAME) }

      before do
        sign_in(user)
        visit new_hangover_path
      end

      it_should_show_the_page_title(spec_translate(:new_hangover))

      context "Filling in the form correctly then pressing '#{spec_translate(:create_hangover)}'" do
        SAMPLE_HANGOVER_TITLE = "Bliiiiind"

        before do
          fill_in(spec_translate(:title), :with => SAMPLE_HANGOVER_TITLE)
          attach_file(spec_translate(:image), image_fixture_path)
          click_button spec_translate(:create_hangover)
        end

        it "should redirect the me to the hangovers page" do
          current_path.should == hangovers_path
        end

        it "should show me '#{spec_translate(:hangover_created)}'" do
          page.should have_content spec_translate(:hangover_created)
        end

        it "should show me the new hangover as the latest hangover" do
          page.should have_content spec_translate(
            :caption,
            :category => summary_categories.first,
            :votes => 0,
            :title => SAMPLE_HANGOVER_TITLE,
            :owner => SAMPLE_DISPLAY_NAME
          )
        end
      end

      context "pressing '#{spec_translate(:create_hangover)}' without filling in the form" do
        before { click_button spec_translate(:create_hangover) }

        context "within" do
          it_should_display_errors_for(:hangover, :title, :cant_be_blank)
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

