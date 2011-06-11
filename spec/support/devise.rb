module Devise::CustomTestHelpers
  def stub_devise(options = {})
    view.stub(:resource).and_return(user)
    view.stub(:resource_name).and_return(:user)
    view.stub(:devise_mapping).and_return(
      Devise.mappings[:user]
    ) if options[:mapping]
    stub_template "devise/shared/_links.html.haml" => "" unless options[:shared_links] == false
  end
end

def it_should_render_devise_shared_links
  it "should render the devise shared links" do
    render
    rendered.should render_template :partial => "devise/shared/_links"
  end
end


RSpec.configure do |config|
  [:controller, :view].each do |type|
    config.include Devise::TestHelpers, :type => type
  end
end

