require 'spec_helper'

describe User do
  let(:unregistered_user) { Factory(:user) }
  let(:registered_user) { Factory(:registered_user) }

  describe "Validations" do

    context "User factory" do
      it "should be valid" do
        unregistered_user.should be_valid
      end
    end

    context "Registered user factory" do
      it "should be valid" do
        registered_user.should be_valid
      end
    end

    context "an unregistered user" do
      before { unregistered_user }

      context "a new user without an email address" do
        let(:second_user) { Factory(:user) }

        # Tests database uniqueness constraint
        it "should save" do
          second_user.save.should be_true
        end
      end
    end

    context "a registered user" do
      before { registered_user }

      it "should not be valid without a password" do
        registered_user.password = nil
        registered_user.should_not be_valid
      end

      it "should not be valid without a display name" do
        registered_user.display_name = nil
        registered_user.should_not be_valid
      end

      context "another user with the same email address" do
        let(:duplicate_user) { Factory.build(
          :registered_user,
          :email => registered_user.email
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

