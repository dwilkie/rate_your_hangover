require 'spec_helper'

def to_xpath_attributes(options = {})
  attributes = []

  options.each do |key, value|
    attributes << "@#{key}='#{value}'"
  end

  attributes.join(" and ")
end

def it_should_have_input(resource_name, input, options = {})
  options[:type] ||= input
  options[:required] ||= "required"
  options[:id] ||= "#{resource_name}_#{input}"
  options[:name] ||= "#{resource_name}[#{input}]"

  xpath_attributes = to_xpath_attributes(options)

  it "should have a label for #{spec_translate(input)}" do
    parent_selector << "label[@for='#{options[:id]}']"
    rendered.should have_parent_selector :text => spec_translate(input)
  end

  it "should have an input for #{spec_translate(input)}" do
    parent_selector << "input[#{xpath_attributes}]"
    rendered.should have_parent_selector
  end
end

def it_should_display_error_messages_for(resource_name, input)
  context input.to_s do
    before { parent_selector << "input[@id='#{resource_name}_#{input}']/.." }

    it "should show '#{spec_translate(:cant_be_blank)}'" do
      rendered.should have_parent_selector, :text => spec_translate(:cant_be_blank)
    end
  end
end

describe "devise/registrations/new.html.haml" do
  include HangoverExampleHelpers

  let(:user) {stub_model(User).as_null_object.as_new_record}
  let(:parent_selector) { [] }

  before do
    view.stub(:resource).and_return(user)
    view.stub(:resource_name).and_return(:user)
    stub_template "devise/shared/_links.html.haml" => ""
  end

  it "should render the shared links" do
    render
    rendered.should render_template :partial => "devise/shared/_links"
  end

  context "within" do
    context "title" do
      before { parent_selector << "title" }

      it "should set the title to: '#{spec_translate(:sign_up)}'" do
        view.should_receive(:title).with(spec_translate(:sign_up))
        render
      end
    end

    context "form" do
      before do
        xpath_attributes = to_xpath_attributes(
          :action => "/users",
          :method => "post"
        )
        parent_selector << "form[#{xpath_attributes}]"
      end

      it "should post to /users" do
        render
        rendered.should have_parent_selector
      end

      context "button" do
        before { render }

        it "should have a button to #{spec_translate(:sign_up)}" do
          xpath_attributes = to_xpath_attributes(
            :name => :commit, :type => :submit, :value => spec_translate(:sign_up)
          )
          parent_selector << "input[#{xpath_attributes}]"
          rendered.should have_parent_selector
        end
      end

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

