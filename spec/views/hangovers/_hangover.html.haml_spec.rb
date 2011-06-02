require 'spec_helper'

describe "hangovers/_hangover.html.haml" do

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
    render [hangover]
  end

  context "within" do
    include HangoverExampleHelpers
    let(:parent_selector) { [] }

    context "div#hangover_1.slide" do
      let(:parent_selector) { ["#hangover_1.slide"] }

      context "div.caption p" do
        before do
          parent_selector << ".caption p"
          do_render
        end

        it "should show the caption" do
          rendered.should have_selector(
            join_parent_selector,
            :text => SAMPLE_CAPTION
          )
        end
      end

      context "hangover is persisted" do
        before { do_render }

        it "should have link to the hangover" do
          parent_selector << "a[href=\"/hangovers/#{SAMPLE_ID}\"]"
          rendered.should have_selector(
            join_parent_selector
          )
        end

        context "a" do
          before { parent_selector << "a" }

          it "should show the image" do
            parent_selector << "img[src=\"#{SAMPLE_IMAGE_URL}\"]"
            rendered.should have_selector(
              join_parent_selector
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
          parent_selector << "a"
          rendered.should_not have_selector(
            join_parent_selector
          )
        end

        it "should still show an image" do
          parent_selector << "img[src=\"#{SAMPLE_IMAGE_URL}\"]"
          rendered.should have_selector(
            join_parent_selector
          )
        end
      end
    end
  end
end

