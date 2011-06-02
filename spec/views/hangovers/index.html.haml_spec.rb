require 'spec_helper'

describe "hangovers/index.html.haml" do

  let(:hangovers) {[mock_model(Hangover)]}

  def do_render
    assign(:hangovers, hangovers)
    render
  end

  before {
    stub_template "hangovers/_hangover.html.haml" => ""
    do_render
  }

  it "should display the hangovers within #hangovers #images" do
    rendered.should have_selector("#hangovers #images")
  end

  #FIXME: move these methods to happen within a selector
  # these methods really should be within a selector
  it "should display a link to the previous image" do
    rendered.should have_selector :xpath, './/a[@href="#" and @class="prev"]'
  end

  it "should display a link to the next image" do
    rendered.should have_selector :xpath, './/a[@href="#" and @class="next"]'
  end

  # It's not possible check for a render within a selector
  # see https://github.com/rspec/rspec-rails/issues/387#comment_1279137
  it "should render the hangovers" do
    rendered.should render_template hangovers
  end

  context "within" do
    include HangoverExampleHelpers

    let(:parent_selector) { [] }

    context "div#hangovers div#images" do
      before { parent_selector << "#hangovers #images" }

      it "should display the frame" do
        parent_selector << ".frame"
        rendered.should have_selector(join_parent_selector)
      end

      it "should display the slides" do
        parent_selector << "#slides"
        rendered.should have_selector(join_parent_selector)
      end

      context "div#slides" do
        before { parent_selector << "#slides"}
        it "should display the slides container" do
          parent_selector << ".slides_container"
          rendered.should have_selector(join_parent_selector)
        end
      end
    end
  end

  it "should show a link to '#{I18n.t("hangover.got_one")}'" do
    rendered.should have_selector "p", :text => I18n.t("hangover.got_one")
  end

end

