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

  # It's not possible check for a render within a selector
  # see https://github.com/rspec/rspec-rails/issues/387
  it "should render the hangovers" do
    rendered.should render_template hangovers
  end

  context "within" do
    include HangoverExampleHelpers

    let(:parent_selector) { [] }

    context "div#hangovers div#images" do
      before { parent_selector << "div[@id='hangovers']/div[@id='images']" }

      it "should display images of hangovers" do
        rendered.should have_parent_selector
      end

      it "should display the frame" do
        parent_selector << "div[@class='frame']"
        rendered.should have_parent_selector
      end

      context "div#slides" do
        before { parent_selector << "div[@id='slides']" }

        it "should display the slides" do
          rendered.should have_parent_selector
        end

        it "should display a link to the previous image" do
          parent_selector << "a[@href='#' and @class='prev']"
          rendered.should have_parent_selector
        end

        it "should display a link to the next image" do
          parent_selector << "a[@href='#' and @class='next']"
          rendered.should have_parent_selector
        end

        it "should display the slides container" do
          parent_selector << "div[@class='slides_container']"
          rendered.should have_parent_selector
        end
      end
    end
  end

  it "should show a link to '#{I18n.t("hangover.got_one")}'" do
    rendered.should have_selector "p", :text => I18n.t("hangover.got_one")
  end

end

