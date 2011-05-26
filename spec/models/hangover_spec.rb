require 'spec_helper'

describe Hangover do

  SUMMARY_CATEGORIES = [
    "Latest Hangover", "Best Hangover",
    "Hangover of the Day", "Hangover of the Week",
    "Hangover of the Month", "Hangover of the Year"
  ]

  def vote(hangover, number_of_votes = 1)
    number_of_votes.times do
      Factory.create(
        :hangover_vote, :voteable => hangover
      )
    end
  end

  def previous_hangover(time_period, time_quantity = 1)
    Factory.create(:hangover, :created_at => time_quantity.send(time_period).ago)
  end

  let(:hangover) { Factory(:hangover) }

  describe "Validations" do
    it "Factory should be valid" do
      hangover.should be_valid
    end

    context "without a title" do
      before { hangover.title = nil }

      it "should not be valid" do
        hangover.should_not be_valid
      end
    end

    context "without a user" do
      before { hangover.user = nil }

      it "should not be valid" do
        hangover.should_not be_valid
      end
    end

  end

  describe "Associations" do
    it "should belong to a user" do
      subject.should respond_to(:user)
    end

    it "should have many votes" do
      subject.should respond_to(:votes)
    end
  end

  shared_examples_for(".of_the_time_period") do

    let(:past_hangover) {
      previous_hangover(time_period)
    }

    context "when a hangover was created in this time period" do
      before do
        hangover.update_attributes!(
          :created_at => Time.now.utc.send("beginning_of_#{time_period}")
        )
      end

      it "should return the hangover" do
        Hangover.send("of_the_#{time_period}").should == hangover
      end

      context "and a hangover was created outside this time period with 2 votes" do
        before { vote(past_hangover, 2) }

        it "should return this time period's hangover" do
          Hangover.send("of_the_#{time_period}").should == hangover
        end
      end

      context "and another hangover was created in this time period with more votes" do
        let(:popular_hangover) { previous_hangover time_period, 0 }
        before { vote(popular_hangover, 1) }

        it "should return the hangover with more votes" do
          Hangover.send("of_the_#{time_period}").should == popular_hangover
        end
      end
    end

    context "when no hangovers were created in this time period" do
      it "should return nil" do
        Hangover.send("of_the_#{time_period}").should be_nil
      end
    end
  end

  describe ".of_the_day" do
    it_should_behave_like ".of_the_time_period" do
      let(:time_period) { :day }
    end
  end

  describe ".of_the_week" do
    it_should_behave_like ".of_the_time_period" do
      let(:time_period) { :week }
    end
  end

  describe ".of_the_month" do
    it_should_behave_like ".of_the_time_period" do
      let(:time_period) { :month }
    end
  end

  describe ".of_the_year" do
    it_should_behave_like ".of_the_time_period" do
      let(:time_period) { :year }
    end
  end

  describe ".of_all_time" do
    let(:best_hangover) { Factory.create(:hangover) }
    before do
      hangover
      vote(best_hangover, 2)
    end

    it "should return the best hangover" do
      Hangover.of_all_time.should == best_hangover
    end
  end

  describe ".inventory" do
    context "passing no args" do
      it "should call .summary" do
        Hangover.should_receive(:summary)
        Hangover.inventory
      end
    end

    context "passing nil" do
      it "should call .summary" do
        Hangover.should_receive(:summary)
        Hangover.inventory(nil)
      end
    end
  end

  describe ".summary" do
    it "should return an array" do
      Hangover.summary.should be_a(Array)
    end

    context "no hangovers exist" do
      it "should return an empty array" do
        Hangover.summary.should be_empty
      end
    end

    context "a hangover exists" do
      before { hangover }

      shared_examples_for "a summary hangover" do
        context "the xth element" do
          it "should be the hangover" do
            Hangover.summary[summary_index].should == hangover
          end

          context "caption" do
            it "should include the caption" do
              Hangover.summary[summary_index].caption.should include(caption)
            end
          end
        end
      end

      SUMMARY_CATEGORIES.each_with_index do |summary_category, index|
        it_should_behave_like "a summary hangover" do
          let(:summary_index) { index }
          let(:caption) { summary_category }
        end
      end
    end
  end

  describe "#build_caption" do
    before { subject.title = "Alan" }
    it "should build the caption from the argument and title" do
      subject.build_caption("Biggest Hangover")
      subject.caption.should == 'Biggest Hangover - "Alan"'
    end
  end
end

