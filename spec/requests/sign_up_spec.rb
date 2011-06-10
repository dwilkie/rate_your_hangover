require 'spec_helper'

def it_should_display_errors_for(field, message)
  context field.to_s do
    it "should show #{spec_translate(message)}" do
      within(:xpath, ".//input[@id='user_#{field}']/..") do
        page.should have_content spec_translate(message)
      end
    end
  end
end

describe "Sign up" do
  describe "GET /users/sign_up" do
    before { visit new_user_registration_path }
    context "the page title" do
      it "should be '#{spec_translate(:sign_up)}' in the browser window" do
        within("title") do
          page.should have_content "#{spec_translate(:sign_up)}"
        end
      end

      it "should be '#{spec_translate(:sign_up)}' in h1" do
        within("h1") do
          page.should have_content "#{spec_translate(:sign_up)}"
        end
      end
    end

    context "Filling in the form correctly then pressing #{spec_translate(:sign_up)}" do
      before do
        fill_in(spec_translate(:display_name), :with => "Dave")
        fill_in(spec_translate(:email), :with => "dave@example.com")
        fill_in(spec_translate(:password), :with => "foobar")
        fill_in(spec_translate(:password_confirmation), :with => "foobar")
        click_button spec_translate(:sign_up)
      end

      it "should display #{spec_translate(:signed_up)}" do
        page.should have_content spec_translate(:signed_up)
      end

      it "should redirect the user to the homepage" do
        current_path.should == root_path
      end
    end

    context "Pressing #{spec_translate(:sign_up)} without filling in the form" do
      before { click_button spec_translate(:sign_up) }

      context "within" do
        it_should_display_errors_for(:display_name, :cant_be_blank)
        it_should_display_errors_for(:email, :cant_be_blank)
        it_should_display_errors_for(:password, :cant_be_blank)
      end
    end

    context "Clicking the '#{spec_translate(:sign_in)}' link" do
      before { click_link spec_translate(:sign_in) }

      it "should take the user to the sign in page" do
        current_path.should == new_user_session_path
      end
    end

    context "Clicking the '#{spec_translate(:forgot_password)}' link" do
      before { click_link spec_translate(:forgot_password) }

      it "should take the user to the forgot password page" do
        current_path.should == new_user_password_path
      end
    end

  end
end

