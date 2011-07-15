require 'spec_helper'

describe ImageProcessor do
  context "@queue" do
    it "should == :image_processor_queue" do
      ImageProcessor.instance_variable_get(:@queue).should == :image_processor_queue
    end
  end

  SAMPLE_ATTRIBUTES = {
    "title" => "Mot Hai Ba Yo",
    "bliindness_factor" => 1234
  }

  describe ".perform #{SAMPLE_ATTRIBUTES}" do

    EXPLICIT_ATTRIBUTES = ["bliindness_factor"]

    let(:new_hangover) { mock_model(Hangover).as_new_record.as_null_object }

    before do
      Hangover.stub(:new).and_return(new_hangover)
    end

    it "should build a new hangover from the parameters" do
      Hangover.should_receive(:new).with(SAMPLE_ATTRIBUTES)
      ImageProcessor.perform(SAMPLE_ATTRIBUTES)
    end

    it "should tell the hangover to process it's image and save" do
      new_hangover.should_receive(:save_and_process_image).with(:now => true)
      ImageProcessor.perform(SAMPLE_ATTRIBUTES)
    end

    describe EXPLICIT_ATTRIBUTES do
      EXPLICIT_ATTRIBUTES.each do |attribute|
        it "should set #{attribute} = #{SAMPLE_ATTRIBUTES[attribute]} explicitly" do
          new_hangover.should_receive(
            "#{attribute}="
          ).with(SAMPLE_ATTRIBUTES[attribute])
          ImageProcessor.perform(SAMPLE_ATTRIBUTES, EXPLICIT_ATTRIBUTES)
        end
      end
    end
  end
end

