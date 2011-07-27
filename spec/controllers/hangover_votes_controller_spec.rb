require 'spec_helper'

describe HangoverVotesController do
  SAMPLE_DATA = {
    :referrer => "http://rateyourhangover.com/hangovers",
    :hangover_id => 1,
    :error_message => "Vote not valid"
  }.freeze

  describe "POST /hangover_votes" do
    let(:hangover_vote) { mock_model(Vote).as_null_object.as_new_record }
    let(:registered_user) { Factory(:user) }
    let(:unregistered_user) {
      user = Factory.build(:unregistered_user)
      user.save!(:validate => false)
      user
    }

    def do_post
      post :create, :id => sample(:hangover_id)
    end

    before do
      Hangover.stub_chain(:find, :votes, :build).and_return(hangover_vote)
      User.stub(:with_ip).and_return([])
      request.env['HTTP_REFERER'] = sample(:referrer)
    end

    shared_examples_for "save the hangover vote" do

      it "should try to find the hangover from the id" do
        Hangover.should_receive(:find).with(sample(:hangover_id))
        do_post
      end

      it "should build a new hangover for the user" do
        # override stub in before block
        hangover_votes = mock("HangoverVotes")
        Hangover.stub_chain(:find, :votes).and_return(hangover_votes)

        # restub build to return the hangover vote
        hangover_votes.stub(:build).and_return(hangover_vote)

        hangover_votes.should_receive(:build).with(:user => user)
        do_post
      end

      it "should try to save the hangover vote" do
        hangover_vote.should_receive(:save)
        do_post
      end
    end

    context "the user is not signed in" do
      context "another user has signed in with this ip before" do
        before { User.stub(:with_ip).and_return([unregistered_user]) }

        it "should not create a new user" do
          User.should_not_receive(:new)
          do_post
        end

        it "should not sign in the existing user" do
          do_post
          controller.current_user.should_not == unregistered_user
        end

        it "should not remember the new user" do
          unregistered_user.should_not_receive(:remember_me!)
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
              spec_translate(:sign_in), new_user_session_path
            )
          )
        end

        it "the flash message should be html_safe" do
          do_post
          flash[:error].should be_html_safe
        end
      end

      context "there's no record of another user with this ip" do

        let(:new_unregistered_user) { mock_model(User).as_null_object.as_new_record }

        before do
          User.stub(:new).and_return(new_unregistered_user)
          controller.stub(:sign_in)
          User.stub(:with_ip).and_return([])
        end


        it "should create a new unregistered user" do
          new_unregistered_user.should_receive(:save!).with(
            hash_including(:validate => false)
          )
          do_post
        end

        context "the new unregistered user" do

          it "should be signed in" do
            controller.should_receive(:sign_in).with(new_unregistered_user)
            do_post
          end

          it "should be remembered" do
            new_unregistered_user.should_receive(:remember_me!)
            do_post
          end
        end

        it_should_behave_like "save the hangover vote" do
          let(:user) { new_unregistered_user }
        end

      end
    end

    context "user is already signed in" do
      before { sign_in registered_user }

      it_should_behave_like "save the hangover vote" do
        let(:user) { registered_user }
      end
    end

    context "vote saves successfully" do
      before { hangover_vote.stub(:save).and_return(true) }
      it "should set the flash[:notice] to: '#{spec_translate(:you_rate_it)}'" do
        do_post
        flash[:notice].should == spec_translate(:you_rate_it)
      end
    end

    context "vote does not save successfully" do
      before do
        hangover_vote.stub(:save).and_return(false)
        hangover_vote.stub_chain(
          :errors, :full_messages, :to_sentence
        ).and_return(sample(:error_message))
      end

      it "should set the flash[:error] to the errors" do
        do_post
        flash[:error].should == sample(:error_message)
      end
    end

    it "should redirect to the referrer" do
      do_post
      response.should redirect_to sample(:referrer)
    end
  end
end

