require 'spec_helper'

describe Vote do
  let(:vote) { Factory(:hangover_vote) }
  let(:user) { Factory(:user) }
  let(:hangover) { Factory(:hangover) }

  describe "Validations" do

    it "Factory should be valid" do
      vote.should be_valid
    end

    context "without a user" do
      it "should not be valid" do
        vote.user = nil
        vote.should_not be_valid
      end
    end

    context "without a voteable" do
      it "should not be valid" do
        vote.voteable = nil
        vote.should_not be_valid
      end
    end

    context "a vote already exists for this user and hangover" do
      let(:vote) { Factory.create(
        :hangover_vote, :user => user, :voteable => hangover)
      }
      before { vote }
      it "then a duplicate should not be valid" do
        duplicate_vote = Factory.build(
          :hangover_vote, :user => user, :voteable => hangover
        )
        duplicate_vote.should_not be_valid
      end
    end
  end

  describe "Associations" do
    it "should belong to a user" do
      subject.should respond_to(:user)
    end

    it "should belong to a voteable" do
      subject.should respond_to(:voteable)
    end
  end
end

