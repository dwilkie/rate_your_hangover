require 'spec_helper'

describe Notification do

  SAMPLE_DATA = {:message => "Your're off your guts!"}.freeze

  let(:notification) { Factory(:notification) }
  let(:read_notification) { Factory(:read_notification) }
  let(:user) { Factory(:user) }

  # Associations
  it "should belong to a user" do
    subject.should respond_to(:user)
  end

  # Validations
  context "factory" do
    it "should be valid" do
      notification.should be_valid
    end
  end

  context "without a user" do
    before { notification.user = nil }

    it "should not be valid" do
      notification.should_not be_valid
    end
  end

  describe ".unread" do
    context "an unread notification an a read notification exists" do
      before do
        notification
        read_notification
      end

      it "should include the unread notification" do
        subject.class.unread.should include(notification)
      end

      it "should not include the read notification" do
        subject.class.unread.should_not include(read_notification)
      end
    end
  end


  describe ".for_user! <User>" do
    it "should return a notification" do
      subject.class.for_user!(user).should be_a(subject.class)
    end

    context "the returned notification" do
      it "should be persisted" do
        subject.class.for_user!(user).should be_persisted
      end

      it "should belong to the user" do
        subject.class.for_user!(user).user.should == user
      end
    end

    context ":message => '#{sample(:message)}'" do
      it "should set the message" do
        subject.class.for_user!(user, :message => sample(:message)).message.should == sample(:message)
      end
    end
  end
end

