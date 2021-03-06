require 'spec_helper'

def within_caption(&block)
  example_group_class = context "div.caption p" do
    before do
      parent_selector << "div[@class='caption']/p"
    end
  end
  example_group_class.class_eval &block
end

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
      before { parent_selector << "div[@id='hangover_1' and @class='slide']" }

      within_caption do
        it "should show the caption" do
          do_render
          rendered.should have_parent_selector(:text => SAMPLE_CAPTION)
        end
      end

      shared_examples_for "hangover image" do
        it "should be displayed" do
          parent_selector << "img[@src='#{SAMPLE_IMAGE_URL}']"
          rendered.should have_parent_selector
        end
      end

      context "hangover is persisted" do
        before { do_render }

        it "should have link to the hangover" do
          parent_selector << "a[@id='hangover_#{SAMPLE_ID}' and @href='/hangovers/#{SAMPLE_ID}']"
          rendered.should have_parent_selector
        end

        context "a" do
          before { parent_selector << "a" }

          it_should_behave_like "hangover image"
        end
      end

      context "hangover is not persisted" do
        before do
          hangover.as_new_record
          do_render
        end

        it "should not have link to the hangover" do
          parent_selector << "a"
          rendered.should_not have_parent_selector
        end

        it_should_behave_like "hangover image"
      end

      context "hangover has not yet been 'rated' by the current user" do
        before do
          hangover.stub(:rated_by?).and_return(false)
          do_render
        end

        within_caption do
          it "should have a link to: '#{spec_translate(:rate_it)}'" do
            parent_selector << "a[@href='/hangover_votes/#{SAMPLE_ID}' and @data-method='post']"
            rendered.should have_parent_selector(:text => spec_translate(:rate_it))
          end
        end
      end

      context "hangver was already 'rated' by the current user" do
        before do
          hangover.stub(:rated_by?).and_return(true)
          do_render
        end

        within_caption do
          it "should not have a link to: '#{spec_translate(:rate_it)}'" do
            parent_selector << "a"
            rendered.should_not have_parent_selector(:text => spec_translate(:rate_it))
          end
        end
      end
    end
  end
end

