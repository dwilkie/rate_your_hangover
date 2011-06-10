require 'spec_helper'

describe User do
  let(:user) { Factory(:user) }
  let(:unregistered_user) { Factory.build(:unregistered_user) }

  describe "Validations" do

    context "factory" do
      it "should be valid" do
        user.should be_valid
      end
    end

    context "unregistered" do
      it "should not be valid" do
        unregistered_user.should_not be_valid
      end
    end

    context "an unregistered user already exists" do
      before { unregistered_user.save(:validate => false) }

      context "a new unregistered user" do
        let(:second_user) { Factory.build(:unregistered_user) }

        before { second_user.save(:validate => false) }

        # Tests database uniqueness constraint
        it "should save" do
          second_user.save(:validate => false).should be_true
        end
      end
    end

    context "new" do
      let(:new_user) { Factory.build(:user) }

      it "should not be valid without a password" do
        new_user.password = nil
        new_user.should_not be_valid
      end

      it "should not be valid without a display name" do
        new_user.display_name = nil
        new_user.should_not be_valid
      end

      context "another user with the same email address already exists" do
        before { new_user.email = user.email }
        it "should not be valid" do
          new_user.should_not be_valid
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

