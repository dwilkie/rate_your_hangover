require 'spec_helper'

describe "notifications/_notification.html.haml" do

  SAMPLE_DATA = {
    :subject => "Sample Notification Subject",
    :message => "Sample Notification Message",
    :id => 1
  }.freeze

  let(:notification) {
    mock_model(
      Notification,
      :subject => sample(:subject),
      :message => sample(:message),
      :id => sample(:id)
    ).as_null_object
  }

  def do_render
    render [notification]
  end

  context "within" do
    include HangoverExampleHelpers
    let(:parent_selector) { [] }

    context "div#notification_1", :wip => true do
      before { parent_selector << "div[@id='notification_1']" }

      context "a link to the notification" do
        before {  parent_selector << "a[@href='/notifications/#{sample(:id)}']" }

        it "should be shown with the subject as the link text" do
          do_render
          rendered.should have_parent_selector(:text => sample(:subject))
        end

        it "should be shown with a snippit of the message as the link text" do
          do_render
          rendered.should have_parent_selector(:text => snippit(sample(:message)))
        end
      end
    end
  end
end

