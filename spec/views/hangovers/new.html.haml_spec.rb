require 'spec_helper'

describe "hangovers/new.html.haml" do
  include HangoverExampleHelpers

  let(:hangover) { stub_model(Hangover).as_new_record.as_null_object }
  let(:parent_selector) { [] }

  before { assign(:hangover, hangover) }

  it_should_set_the_title(:to => spec_translate(:new_hangover))

  context "form" do
    it_should_submit_to(
      :action => "/hangovers",
      :method => "post",
      :enctype => "multipart/form-data"
    )

    it_should_have_button(:text => spec_translate(:create_hangover))

    context "div" do
      before { parent_selector << "div" }

      context "inputs" do
        before { render }

        it_should_have_input(:hangover, :title, :type => :text)
        it_should_have_input(:hangover, :image, :type => :file)
      end
    end
  end
end

