require 'spec_helper'

describe "Sign up" do
  describe "GET /users/sign_up" do
    before { visit new_user_registration_path }

    it_should_show_the_page_title(spec_translate(:sign_up))

    context "Filling in the form correctly then pressing '#{spec_translate(:sign_up)}'" do
      before do
        fill_in(spec_translate(:display_name), :with => "Dave")
        fill_in(spec_translate(:email), :with => "dave@example.com")
        fill_in(spec_translate(:password), :with => "foobar")
        fill_in(spec_translate(:password_confirmation), :with => "foobar")
        click_button spec_translate(:sign_up)
      end

      it "should display '#{spec_translate(:signed_up)}'" do
        page.should have_content spec_translate(:signed_up)
      end

      it "should redirect the user to the homepage" do
        current_path.should == root_path
      end
    end

    context "Pressing '#{spec_translate(:sign_up)}' without filling in the form" do
      before { click_button spec_translate(:sign_up) }

      context "within" do
        it_should_display_errors_for(:user, :display_name, :cant_be_blank)
        it_should_display_errors_for(:user, :email, :cant_be_blank)
        it_should_display_errors_for(:user, :password, :cant_be_blank)
      end
    end

    context "Clicking the '#{spec_translate(:sign_in)}' link" do
      before { click_link spec_translate(:sign_in) }

      it "should take the user to the sign in page" do
        current_path.should == new_user_session_path
      end
    end

    it_should_behave_like_clicking_forgot_password

  end
end

