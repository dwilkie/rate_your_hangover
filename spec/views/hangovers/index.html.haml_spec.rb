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

  it "should display the hangover's caption" do
    rendered.should include(SAMPLE_CAPTION)
  end

  it "should show a link to '#{I18n.t("hangover.got_one")}'" do
    rendered.should include I18n.t("hangover.got_one")
  end

end

