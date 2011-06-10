require 'spec_helper'

def it_should_render_devise_links(controller_name, link_text, link_href)
  context "not rendered from the #{controller_name} controller" do
    before { view.stub(:controller_name).and_return("not #{controller_name}") }

    it "should have a link to '#{spec_translate(link_text)}'" do
      parent_selector << "a[@href='#{link_href}']"
      render
      rendered.should have_parent_selector(:text => spec_translate(link_text))
    end
  end

  context "rendered from the #{controller_name} controller" do
    before { view.stub(:controller_name).and_return(controller_name.to_s) }

    it "should not have a link to '#{spec_translate(link_text)}'" do
      parent_selector << "a[@href='#{link_href}']"
      render
      rendered.should_not have_parent_selector
    end
  end
end


describe "devise/shared/_links.html.haml" do
  include HangoverExampleHelpers

  let(:parent_selector) { [] }

  before do
    view.stub(:resource_name).and_return(:user)
    view.stub(:devise_mapping).and_return(Devise.mappings[:user])
  end

  it_should_render_devise_links(:sessions, :sign_in, "/users/sign_in")
  it_should_render_devise_links(:passwords, :forgot_password, "/users/password/new")
end

