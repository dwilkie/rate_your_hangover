require 'spec_helper'

describe "Hangovers" do
  describe "GET /" do

    let(:hangover) { Factory(:hangover) }

    context "a hangover exists" do
      before do
        hangover
        visit root_path
      end

      shared_examples_for "caption title" do
        it "should be shown in the caption" do
          page.should have_content caption_title
        end
      end

      caption_titles.each do |caption_title|
        it_should_behave_like "caption title" do
          let(:caption_title) { caption_title }
        end
      end
    end
  end
end

