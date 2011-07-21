require 'spec_helper'

def it_should_have_usernav_link(options = {})
  signed_in = options.delete(:signed_in)
  positive, negative = contexts = ["for a signed in or recognized user", "for a guest"]
  negative, positive = contexts unless signed_in

  it_should_have_conditional_link(
    {
      :user_signed_in? => {
        :value => signed_in,
        :negative => negative,
        :positive => positive
      }
    }, options
  )
end

describe "application/_menu.html.haml" do

  SAMPLE_DATA = {
    :unread_count => 0
  }.freeze

  before do
    assign(:unread_notification_count, sample(:unread_count))
  end

  context "within" do
    include HangoverExampleHelpers
    let(:parent_selector) { [] }

    context "div.usernav ul li" do
      before { parent_selector << "div[@class='usernav']/ul/li" }

      it_should_have_usernav_link(:signed_in => false, :text => spec_translate(:sign_up), :href => "/users/sign_up")
      it_should_have_usernav_link(:signed_in => false, :text => spec_translate(:sign_in), :href => "/users/sign_in")
      it_should_have_usernav_link(
        :signed_in => true,
        :text => sample(:unread_count).to_s,
        :href => "/notifications", :class => :unread_count
      )
    end
  end
end

