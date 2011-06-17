require 'spec_helper'

describe "Sign in" do
  describe "GET /users/sign_in" do
    before { visit new_user_session_path }
    let(:user) { Factory(:user) }

    it_should_show_the_page_title(spec_translate(:sign_in))

    context "Filling in the form correctly then pressing '#{spec_translate(:sign_in)}'" do
      before do
        user
        fill_in(spec_translate(:email), :with => user.email)
        fill_in(spec_translate(:password), :with => "secret")
        click_button spec_translate(:sign_in)
      end

      it "should display '#{spec_translate(:signed_in)}'" do
        page.should have_content spec_translate(:signed_in)
      end

      it "should redirect the user to the homepage" do
        current_path.should == root_path
      end
    end

    context "Pressing '#{spec_translate(:sign_in)}' without filling in the form" do
      before { click_button spec_translate(:sign_in) }

      it "should display '#{spec_translate(:incorrect_credentials)}'" do
        page.should have_content spec_translate(:incorrect_credentials)
      end

    end

    context "Clicking the '#{spec_translate(:sign_up)}' link" do
      before { click_link spec_translate(:sign_up) }

      it "should take the user to the sign up page" do
        current_path.should == new_user_registration_path
      end
    end

    it_should_behave_like_clicking_forgot_password

  end
end

