require 'spec_helper'

describe "devise/sessions/_menu.html.haml" do

  before { render }

  # specifies no menu
  it "should render nothing" do
    rendered.should be_empty
  end
end

