def it_should_have_accessor(name, options = {})
  if name.is_a?(Hash)
    key = name.keys.first
    sample_data = name[key]
    name = key
  else
    sample_data = "sample #{name}"
  end

  it "should respond to ##{name}=" do
    subject.should respond_to("#{name}=")
  end

  describe "##{name}" do

    context "where the #{name} is set to '#{sample_data}'" do
      before { subject.send("#{name}=", sample_data) }

      it "should be '#{sample_data}'" do
        subject.send(name).should == sample_data
      end

    end

    if options[:accessible]
      describe "when initialized with .new(:#{name} => '#{sample_data}')" do
        let(:new_instance) { subject.class.send(:new, { name => sample_data }) }

        it "should be '#{sample_data}'" do
          new_instance.send(name).should == sample_data
        end

      end
    end
  end
end

