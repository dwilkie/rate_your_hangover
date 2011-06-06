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
      before { vote.user = nil }
      it "should not be valid" do
        vote.should_not be_valid
      end
    end

    context "without a voteable" do
      before { vote.voteable = nil }
      it "should not be valid" do
        vote.should_not be_valid
      end
    end

    context "a vote already exists for this user and hangover" do
      before { vote.update_attributes(:user => user, :voteable => hangover) }

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

  describe ".by_user" do
    context "user has voted" do

      before { vote.update_attributes(:user => user) }

      it "should include the user's vote" do
        Vote.by_user(user).should include(vote)
      end
    end

    context "user has not voted" do

      it "should not include the user's vote" do
        Vote.by_user(user).should_not include(vote)
      end
    end
  end

end

