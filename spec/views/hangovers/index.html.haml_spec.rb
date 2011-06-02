require 'spec_helper'

describe "hangovers/index.html.haml" do

  let(:hangovers) {[]}

  def do_render
    assign(:hangovers, hangovers)
    render
  end

  it "should render the hangovers" do
    rendered.should render_template hangovers
  end

  it "should show a link to '#{I18n.t("hangover.got_one")}'" do
    do_render
    rendered.should have_selector "p", :text => I18n.t("hangover.got_one")
  end

end

