require 'spec_helper'

describe HangoverVotesController do
  SAMPLE_ID = 1

  describe "POST /hangover_votes" do
    let(:hangover) { mock_model(Hangover).as_null_object }
    let(:user) { mock_model(User).as_null_object }

    def do_post
      post :create, :id => SAMPLE_ID
    end

    before do
      Hangover.stub(:find).with(SAMPLE_ID).and_return(hangover)
    end

    it "should find the hangover" do
      Hangover.should_receive(:find).with(SAMPLE_ID)
      do_post
    end

    it "should create a new vote for the hangover" do
      hangover.votes.should_receive(:create).with(:user => user)
      do_post
    end

  end
end

