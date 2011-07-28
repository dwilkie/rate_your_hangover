require 'spec_helper'

describe NotificationsController do

  SAMPLE_DATA = {:id => 1}.freeze

  let(:notification) { mock_model(Notification).as_null_object }
  let(:current_user) { Factory(:user) }
  let(:notifications) { mock(ActiveRecord::Relation).as_null_object }

  before do
    controller.stub(:current_user).and_return(current_user)
    current_user.stub(:notifications).and_return(notifications)
  end

  describe "GET /notifications" do

    def do_index
      get :index
    end

    context "user is signed in" do
      before { sign_in current_user }

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
  end

  describe "GET /notifications/#{sample(:id)}" do

    def do_show
      get :show, :id => sample(:id)
    end

    context "user is signed in" do
      before do
        sign_in current_user
        notifications.stub(:find).and_return(notification)
      end

      it "should render the show template" do
        do_show
        response.should render_template(:show)
      end

      it "should try to find the notification from the current user" do
        notifications.should_receive(:find).with(sample(:id))
        do_show
      end

      it "should assign '@notification'" do
        do_show
        assigns[:notification].should == notification
      end
    end

    it_should_behave_like "an action which requires authentication" do
      let(:action) { :do_show }
    end

  end
end

