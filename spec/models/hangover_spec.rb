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
end

