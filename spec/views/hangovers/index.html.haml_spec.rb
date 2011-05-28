require 'spec_helper'

describe "hangovers/index.html.haml" do

  SAMPLE_CAPTION = "Hangover of the day - 'Steami', 456 Votes"

  let(:hangovers) {[
    mock_model(
      Hangover,
      :caption => SAMPLE_CAPTION
    ).as_null_object
  ]}

  before { assign(:hangovers, hangovers) }

  it "should display the hangover's image" do
    render
    #rendered.should have_tag
  end

  it "should display the hangover's caption" do
    render
    rendered.should include(SAMPLE_CAPTION)
  end

end

