require 'spec_helper'

describe HangoverVotesController do
  SAMPLE_ID = 1
  SAMPLE_REFERRER = "http://rateyourhangover.com/hangovers"

  describe "POST /hangover_votes" do
    let(:hangover) { mock_model(Hangover).as_null_object }
    let(:user) { Factory(:user) }

    def do_post
      post :create, :id => SAMPLE_ID
    end

    before do
      Hangover.stub(:find).with(SAMPLE_ID).and_return(hangover)
      User.stub(:create!).and_return(user)
      request.env['HTTP_REFERER'] = SAMPLE_REFERRER
    end

    it "should find the hangover" do
      Hangover.should_receive(:find).with(SAMPLE_ID)
      do_post
    end

    shared_examples_for "a new hangover vote" do
      it "should create one" do
        hangover.votes.should_receive(:create).with(:user => user)
        do_post
      end
    end

    context "no user is signed in" do
      shared_examples_for "create and remember a new user" do
        it "should create a new user" do
          User.should_receive(:create!)
          action.call
        end

        it "should remember that new user" do
          user.should_receive(:remember_me!)
          action.call
        end
      end

      it_should_behave_like "create and remember a new user" do
        let(:action) { Proc.new { do_post} }
      end

      it_should_behave_like "a new hangover vote"
    end

    context "user is already signed in" do
      before { sign_in user }

      shared_examples_for "get the current user from the session" do
        it "should not create a new user" do
          User.should_not_receive(:create!)
          action.call
        end

        it "should not try an remember any users" do
          user.should_not_receive(:remember_me!)
          action.call
        end
      end

      it_should_behave_like "get the current user from the session" do
        let(:action) { Proc.new { do_post } }
      end

      it_should_behave_like "a new hangover vote"

    end

    it "should redirect to the referrer" do
      do_post
      response.should redirect_to SAMPLE_REFERRER
    end
  end
end

