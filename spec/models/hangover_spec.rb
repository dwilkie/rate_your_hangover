require 'spec_helper'

describe Hangover do
  let(:hangover) { Factory(:hangover) }

  describe "Validations" do
    it "Factory should be valid" do
      hangover.should be_valid
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
      Factory.create(:hangover, :created_at => 1.send(time_period).ago)
    }

    context "when a single hangover was created in this time period" do
      before do
        hangover.update_attributes!(
          :created_at => Time.now.utc.send("beginning_of_#{time_period}")
        )
      end

      it "should return the hangover" do
        Hangover.send("of_the_#{time_period}").should == hangover
      end

      context "and a hangover was created in this time period with 2 votes" do
        before do
          2.times do
            Factory.create(
              :hangover_vote, :voteable => past_hangover
            )
          end
        end

        it "should return this time period's hangover" do
          Hangover.send("of_the_#{time_period}").should == hangover
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
end

