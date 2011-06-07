require 'spec_helper'

describe HangoverVotesController do
  SAMPLE_REFERRER = "http://rateyourhangover.com/hangovers"

  describe "POST /hangover_votes" do
    let(:hangover_vote) { mock_model(Vote).as_null_object.as_new_record }
    let(:user) { Factory(:user) }

    def do_post
      post :create, :id => 1
    end

    before do
      Hangover.stub_chain(:find, :votes, :build).and_return(hangover_vote)
      User.stub(:with_ip).and_return([])
      request.env['HTTP_REFERER'] = SAMPLE_REFERRER
    end

    shared_examples_for "save the hangover vote" do
      it "should try to save the hangover vote" do
        hangover_vote.should_receive(:save)
        do_post
      end
    end

    context "the user is not signed in" do
      context "another user has signed in with this ip before" do
        before { User.stub(:with_ip).and_return([user]) }

        it "should not create a new user" do
          User.should_not_receive(:create!)
          do_post
        end

        it "should not sign in the existing user" do
          do_post
          controller.current_user.should_not == user
        end

        it "should not remember the new user" do
          user.should_not_receive(:remember_me!)
          do_post
        end

        it "should not try to save the hangover vote" do
          hangover_vote.should_not_receive(:save)
          do_post
        end

        it "should set the flash[:error] to tell the user to sign in" do
          do_post
          flash[:error].should == I18n.t(
            "hangover.sign_in_to_rate_it",
            :sign_in_link => controller.view_context.link_to(
              "Sign in", new_user_session_path
            )
          )
        end

        it "the flash message should be html_safe" do
          do_post
          flash[:error].should be_html_safe
        end

      end

      context "there's no record of another user with this ip" do
        before do
          User.stub(:create!).and_return(user)
          User.stub(:with_ip).and_return([])
        end

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

        it_should_behave_like "save the hangover vote"

      end
    end

    context "user is already signed in" do
      before { sign_in user }

      it_should_behave_like "save the hangover vote"
    end

    context "vote saves successfully" do
      before { hangover_vote.stub(:save).and_return(true) }
      it "should set the flash[:notice] to: '#{you_rate_it}'" do
        do_post
        flash[:notice].should == you_rate_it
      end
    end

    context "vote does not save successfully" do
      SAMPLE_ERROR_MESSAGE = "Vote not valid"
      before do
        hangover_vote.stub(:save).and_return(false)
        hangover_vote.stub_chain(
          :errors, :full_messages, :to_sentence
        ).and_return(SAMPLE_ERROR_MESSAGE)
      end

      it "should set the flash[:error] to the errors" do
        do_post
        flash[:error].should == SAMPLE_ERROR_MESSAGE
      end
    end

    it "should redirect to the referrer" do
      do_post
      response.should redirect_to SAMPLE_REFERRER
    end
  end
end

