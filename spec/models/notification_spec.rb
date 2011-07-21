require 'spec_helper'

describe Notification do

  let(:notification) { Factory(:notification) }
  let(:read_notification) { Factory(:read_notification) }

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
end

