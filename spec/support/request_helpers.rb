module RequestHelpers
  def self.included(base)
    base.extend ClassMethods
  end

  def sign_in(user)
    visit new_user_session_path
    fill_in 'Email', :with => user.email
    fill_in 'Password', :with => 'secret'
    click_button(spec_translate(:sign_in))
  end

  def sign_out
    visit destroy_user_session_path
  end

  module ClassMethods
    def it_should_show_the_page_title(title)
      context "the page title" do
        it "should be '#{title}' in the browser window" do
          within("title") do
            page.should have_content title
          end
        end

        it "should be '#{title}' in h1" do
          within("h1") do
            page.should have_content title
          end
        end
      end
    end

    def it_should_display_errors_for(resource, field, message)
      context field.to_s do
        it "should show #{spec_translate(message)}" do
          within(:xpath, ".//input[@id='#{resource}_#{field}']/..") do
            page.should have_content spec_translate(message)
          end
        end
      end
    end

    def it_should_behave_like_clicking_forgot_password
      context "Clicking the '#{spec_translate(:forgot_password)}' link" do
        before { click_link spec_translate(:forgot_password) }

        it "should take the user to the forgot password page" do
          current_path.should == new_user_password_path
        end
      end
    end
  end
end

