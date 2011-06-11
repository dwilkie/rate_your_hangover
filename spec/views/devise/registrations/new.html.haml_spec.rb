require 'spec_helper'

describe "devise/registrations/new.html.haml" do
  include HangoverExampleHelpers
  include Devise::CustomTestHelpers

  let(:user) {stub_model(User).as_null_object.as_new_record}
  let(:parent_selector) { [] }

  before { stub_devise }

  it_should_render_devise_shared_links
  it_should_set_the_title(:to => spec_translate(:sign_up))

  context "within" do
    context "form" do
      it_should_submit_to(:action => "/users", :method => "post")
      it_should_have_button(:text => spec_translate(:sign_up))

      context "div" do
        before { parent_selector << "div" }

        context "inputs" do
          before { render }

          it_should_have_input(:user, :display_name, :type => :text)
          it_should_have_input(:user, :email)
          it_should_have_input(:user, :password)
          it_should_have_input(:user, :password_confirmation, :type => :password)
        end

        context "error messages" do
          before do
            user.stub_chain(:errors, :[]).and_return(
              [spec_translate(:cant_be_blank)]
            )
            render
          end

          it_should_display_error_messages_for(:user, :display_name)
          it_should_display_error_messages_for(:user, :email)
          it_should_display_error_messages_for(:user, :password)
        end
      end
    end
  end
end

