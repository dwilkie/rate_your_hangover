module ControllerHelpers
  shared_examples_for "an action which requires authentication" do
    context "user is not signed in" do
      it "should redirect the user to sign in" do
        send(action)
        response.should redirect_to new_user_session_path
      end
    end
  end
end

RSpec.configure do |config|
  config.include ControllerHelpers, :type => :controller
end

