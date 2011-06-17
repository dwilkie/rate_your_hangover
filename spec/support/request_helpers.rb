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

def it_should_display_errors_for(field, message)
  context field.to_s do
    it "should show #{spec_translate(message)}" do
      within(:xpath, ".//input[@id='user_#{field}']/..") do
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

