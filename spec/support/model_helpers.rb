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

      it "should == '#{sample_data}'" do
        subject.send(name).should == sample_data
      end

    end

    describe "when initialized with .new(:#{name} => '#{sample_data}')" do
      let(:accessor_value) {
        subject.class.send(:new, { name => sample_data }).send(name)
      }

      if options[:accessible]
        it "should == '#{sample_data}'" do
          accessor_value.should == sample_data
        end
      else
        it "should be nil" do
          accessor_value.should be_nil
        end
      end
    end
  end
end

