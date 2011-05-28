require 'spec_helper'

describe "Hangovers" do
  describe "GET /" do

    let(:hangover) {
      Factory.create(:hangover, :title => "Wasted")
    }

    context "a hangover exists" do
      before { hangover }

      shared_examples_for "showing the category" do
        it "should be shown as the caption" do
          visit root_path
          page.should have_content 'Latest Hangover - "Wasted"'
        end
      end

      it_should_behave_like("showing the category") do

      end



      it "should be shown as the latest" do
        visit root_path
        page.should have_content 'Latest Hangover - "Wasted"'
      end

      it "should be shown as the hangover of the day" do
        visit root_path
        page.should have_content 'Hangover of the Day - "Wasted"'
      end
    end
  end
end

