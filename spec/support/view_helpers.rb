def to_xpath_attributes(options = {})
  attributes = []

  options.each do |key, value|
    attributes << ((value == false) ? "not(@#{key})" : "@#{key}='#{value}'")
  end

  attributes.join(" and ")
end

def it_should_have_button(options = {})
  context "button" do
    before { render }

    it "should have a button '#{options[:text]}'" do
      xpath_attributes = to_xpath_attributes(
        :name => :commit, :type => :submit, :value => options[:text]
      )
      parent_selector << "input[#{xpath_attributes}]"
      rendered.should have_parent_selector
    end
  end
end

def it_should_set_the_title(options = {})
  context "title" do
    it "should be set to: '#{options[:to]}'" do
      view.should_receive(:title).with(options[:to])
      render
    end
  end
end

def it_should_submit_to(options = {})
  before do
    xpath_attributes = to_xpath_attributes(options)
    parent_selector << "form[#{xpath_attributes}]"
  end

  it "should post to #{options[:action]}" do
    render
    rendered.should have_parent_selector
  end
end

def it_should_have_input(resource_name, input, options = {})
  options[:type] ||= input
  options[:id] ||= "#{resource_name}_#{input}"
  options[:name] ||= "#{resource_name}[#{input}]"
  options[:required] ||= "required" unless options[:required] == false

  has_label = true unless options[:type].to_sym == :hidden

  input_text = has_label ? spec_translate(input) : input
  xpath_attributes = to_xpath_attributes(options)

  if has_label
    it "should have a label for '#{spec_translate(input)}'" do
      parent_selector << "label[@for='#{options[:id]}']"
      rendered.should have_parent_selector :text => spec_translate(input)
    end
  end

  it "should have an input for '#{input_text}'" do
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

