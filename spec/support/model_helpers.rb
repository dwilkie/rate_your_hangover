def it_should_have_accessor(name, options = {})
  it "should respond to ##{name}=" do
    subject.should respond_to("#{name}=")
  end


  sample_data = "sample #{name}"

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

