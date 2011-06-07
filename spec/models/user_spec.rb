require 'spec_helper'

describe User do
  let(:user) { Factory(:user) }
  let(:registered_user) { Factory(:registered_user) }

  describe "Validations" do

    context "User factory" do
      it "should be valid" do
        user.should be_valid
      end
    end

    context "Registered user factory" do
      it "should be valid" do
        registered_user.should be_valid
      end
    end

    context "an unregistered user" do
      before { user }

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

  describe ".with_ip" do
    SAMPLE_IP = "127.0.0.1"

    shared_examples_for "find the user by ip" do
      it "should contain the user" do
        User.with_ip(SAMPLE_IP).should include(user)
      end
    end

    context "the user is currently signed in" do
      before do
        user.current_sign_in_ip = SAMPLE_IP
        user.save!
      end

      it_should_behave_like "find the user by ip"
    end

    context "user was previously signed in with this ip" do
      before do
        user.last_sign_in_ip = SAMPLE_IP
        user.save!
      end

      it_should_behave_like "find the user by ip"
    end

    context "user is not or was prevously not signed in with this ip address" do
      it "should not contain the user" do
        User.with_ip(SAMPLE_IP).should_not include(user)
      end
    end
  end
end

