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
      request.env['HTTP_REFERER'] = SAMPLE_REFERRER
    end

    it "should try to find the hangover" do
      Hangover.should_receive(:find).with(SAMPLE_ID)
      do_post
    end

    context "no user is signed in" do
      before { User.stub(:create!).and_return(user) }

      it "should create a new user" do
        User.should_receive(:create!)
        do_post
      end

      it "should sign in the new user" do
        do_post
        controller.current_user.should == user
      end

      it "should remember the new user" do
        user.should_receive(:remember_me!)
        do_post
      end

      it "should try and create a hangover vote from the new user" do
        hangover.votes.should_receive(:create).with(:user => user)
        do_post
      end
    end

    context "user is already signed in" do
      before { sign_in user }

      it "should try and create a hangover vote from the current user" do
        hangover.votes.should_receive(:create).with(:user => user)
        do_post
      end
    end

    context "vote saves successfully" do
      before { hangover.votes.stub(:create).and_return(true) }
      it "should set the flash message to: '#{you_rate_it}'" do
        do_post
        flash[:notice].should == you_rate_it
      end
    end

    it "should redirect to the referrer" do
      do_post
      response.should redirect_to SAMPLE_REFERRER
    end
  end
end

