require 'spec_helper'

describe "hangovers/index.html.haml" do

  SAMPLE_CAPTION = "Hangover of the day - 'Steami', 456 Votes"
  SAMPLE_ID = 1
  SAMPLE_IMAGE_URL = "/path/to/hangover/image.png"

  let(:hangover) {
    mock_model(
      Hangover,
      :caption => SAMPLE_CAPTION,
      :id => SAMPLE_ID,
      :image_url => SAMPLE_IMAGE_URL
    ).as_null_object
  }

  def do_render
    assign(:hangovers, [hangover])
    render
  end

  context "within #hangover_1 .slide" do
    let(:css) { ["#hangover_1 .slide"] }

    context ".caption p" do
      before do
        css << ".caption p"
        do_render
      end

      it "should show the caption" do
        rendered.should have_selector(
          css.join(" "),
          :text => SAMPLE_CAPTION
        )
      end
    end

    context "hangover is persisted" do
      before { do_render }

      it "should have link to the hangover" do
        css << "a[href=\"/hangovers/#{SAMPLE_ID}\"]"
        rendered.should have_selector(
          css.join(" ")
        )
      end

      context "a" do
        before { css << "a" }

        it "should show the image" do
          css << "img[src=\"#{SAMPLE_IMAGE_URL}\"]"
          rendered.should have_selector(
            css.join(" ")
          )
        end
      end
    end

    context "hangover is not persisted" do
      before do
        hangover.as_new_record
        do_render
      end

      it "should not have link to the hangover" do
        css << "a"
        rendered.should_not have_selector(
          css.join(" ")
        )
      end

      it "should still show an image" do
        css << "img[src=\"#{SAMPLE_IMAGE_URL}\"]"
        rendered.should have_selector(
          css.join(" ")
        )
      end
    end
  end

  it "should show a link to '#{I18n.t("hangover.got_one")}'" do
    do_render
    rendered.should have_selector "p", :text => I18n.t("hangover.got_one")
  end

end

