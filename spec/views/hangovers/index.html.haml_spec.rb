require 'spec_helper'

describe "hangovers/index.html.haml" do

  SAMPLE_CAPTION = "Hangover of the day - 'Steami', 456 Votes"

  let(:hangovers) {[
    mock_model(
      Hangover,
      :caption => SAMPLE_CAPTION
    ).as_null_object
  ]}

  before do
    assign(:hangovers, hangovers)
    render
  end

  context "within .caption" do
    it "should display the caption" do
      rendered.should have_selector ".caption p", :text => SAMPLE_CAPTION
    end
  end

  it "should show a link to '#{I18n.t("hangover.got_one")}'" do
    rendered.should have_selector "p", :text => I18n.t("hangover.got_one")
  end

end

