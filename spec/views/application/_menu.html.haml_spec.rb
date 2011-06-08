    context "div#menu ul li" do
      before { parent_selector << "div[@id='menu']/ul/li" }

      it "should show a link to '#{spec_translate(:sign_up)}'" do
        parent_selector << "a[@href='/users/sign_up']"
        rendered.should have_parent_selector :text => spec_translate(:sign_up)
      end

      it "should show a link to '#{spec_translate(:sign_in)}'" do
        parent_selector << "a[@href='/users/sign_in']"
        rendered.should have_parent_selector :text => spec_translate(:sign_in)
      end
    end

