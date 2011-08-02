require 'spec_helper'

describe "hangovers/new.html.haml" do
  include HangoverExampleHelpers

  let(:form_inputs) { { :remote_image_net_url => "", :title => "" } }

  let(:hangover) { stub_model(Hangover, form_inputs).as_new_record.as_null_object }
  let(:parent_selector) { [] }

  # given in the callback url from Amazon
  # http://aws.amazon.com/articles/1434?_encoding=UTF8
  hidden_field = :key

  before do
    assign(:hangover, hangover)
    hangover.stub(hidden_field).and_return(hidden_field)
  end

  it_should_set_the_title(:to => spec_translate(:new_hangover))

  context "form" do
    it_should_submit_to(
      :action => "/hangovers",
      :method => "post",
    )

    it_should_have_button(:text => spec_translate(:create_hangover))

    context "div" do
      before { parent_selector << "div" }

      context "inputs" do
        before { render }

        it_should_have_input(:hangover, :title, :type => :text)
        it_should_have_input(:hangover, :remote_image_net_url, :type => :url)
      end

      context "error messages" do
        before do
          hangover.stub_chain(:errors, :[]).and_return(
            [spec_translate(:cant_be_blank)]
          )
          render
        end

        it_should_display_error_messages_for(:hangover, :title)
        it_should_display_error_messages_for(:hangover, :remote_image_net_url)
      end
    end

    it_should_have_input(
      :hangover, hidden_field, :type => :hidden,
      :value => hidden_field, :required => false
    )

  end
end

