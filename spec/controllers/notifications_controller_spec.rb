require 'spec_helper'

describe NotificationsController do

  describe "GET /notifications", :wip => true do

    let(:notification) { mock_model(Notification).as_null_object }
    let(:notifications) { mock(ActiveRecord::Relation).as_null_object }
    let(:current_user) { Factory(:user) }

    def do_index
      get :index
    end

    context "user is signed in" do
      before do
        sign_in current_user
        controller.stub(:current_user).and_return(current_user)
        current_user.stub(:notifications).and_return(notifications)
      end

      it "should render the index template" do
        do_index
        response.should render_template(:index)
      end

      it "should assign '@notifications'" do
        do_index
        assigns[:notifications].should == notifications
      end
    end

    it_should_behave_like "an action which requires authentication" do
      let(:action) { :do_index }
    end

#    before do
#      Hangover.stub(:inventory).and_return(hangovers)
#    end

#    it "should get the inventory" do
#      Hangover.should_receive(:inventory)
#      do_index
#    end

  end
end

