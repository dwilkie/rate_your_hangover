require 'spec_helper'

describe "notifications/show.html.haml", :wip => true do
  include HangoverExampleHelpers

  SAMPLE_DATA = {
    :subject => "Sample Notification Subject",
    :message => "Sample Notification Message"
  }.freeze

  let(:notification) {
    mock_model(
      Notification,
      :subject => sample(:subject),
      :message => sample(:message)
    )
  }

  let(:parent_selector) { [] }

  before do
    assign(:notification, notification)
  end

  it_should_set_the_title(:to => sample(:subject))

  it "should show the message" do
    render
    rendered.should have_content(sample(:message))
  end

end

