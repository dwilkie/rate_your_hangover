require 'spec_helper'

describe "devise/sessions/new.html.haml" do
  include HangoverExampleHelpers
  include Devise::CustomTestHelpers

  let(:user) {stub_model(User).as_null_object.as_new_record}
  let(:parent_selector) { [] }

  before do
    stub_devise(:mapping => true)
    render
  end

  it_should_render_devise_shared_links(:do_render => false)
  it_should_set_the_title(:to => spec_translate(:sign_in))

  context "form" do
    it_should_submit_to(:action => "/users/sign_in", :method => "post", :do_render => false)
    it_should_have_button(:text => spec_translate(:sign_in))


    context "div" do
      before { parent_selector << "div" }

      context "inputs" do
        it_should_have_input(:user, :email)
        it_should_have_input(:user, :password)
      end

      context "error messages" do
        before do
          user.stub_chain(:errors, :[]).and_return(
            [spec_translate(:cant_be_blank)]
          )
          render
        end

        it_should_display_error_messages_for(:user, :email)
        it_should_display_error_messages_for(:user, :password)
      end
    end
  end
end

