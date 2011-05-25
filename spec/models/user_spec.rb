require 'spec_helper'

describe User do
  let(:user) { Factory(:user) }

  describe "Validations" do
    it "Factory should be valid" do
      user.should be_valid
    end

    context "an existing user without an email address" do
      before { user.update_attributes!(:email => nil) }

      context "a new user without an email address" do
        let(:second_user) { Factory(:user, :email => nil) }

        # Tests database uniqueness constraint
        it "should save" do
          second_user.save.should be_true
        end
      end
    end

    context "a user with an email address" do
      before { user.email = "dave@example.com" }

      it "should not be valid without a password" do
        user.password = nil
        user.should_not be_valid
      end

    end

    context "an existing user with an email address" do
      before do
        user.update_attributes!(
          :email => "dave@example.com",
          :password => "foobar"
        )
      end

      context "another user with the same email address" do
        let(:duplicate_user) { Factory.build(
          :user,
          :email => user.email,
          :password => "foobar"
        )}
        it "should not be valid" do
          duplicate_user.should_not be_valid
        end
      end
    end
  end

  describe "Associations" do
    it "should have many votes" do
      subject.should respond_to(:votes)
    end

    it "should have many hangovers" do
      subject.should respond_to(:hangovers)
    end
  end
end
