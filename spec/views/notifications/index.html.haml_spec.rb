require 'spec_helper'

describe "notifications/index.html.haml" do

  SAMPLE_DATA = { :notification => "Sample notification content"}

  let(:notifications) {[mock_model(Notification)]}

  def do_render
    assign(:notifications, notifications)
    render
  end

  before do
    stub_template "notifications/_notification.html.haml" => sample(:notification)
    do_render
  end

  context "within" do
    include HangoverExampleHelpers

    let(:parent_selector) { [] }

    context "div#notifications" do
      before { parent_selector << "div[@id='notifications']" }

      it "should be rendered" do
        rendered.should have_parent_selector
      end

      it "should render the notifications" do
        rendered.should have_parent_selector(:text => sample(:notification))
      end
    end
  end
end

