require 'spec_helper'

describe ImageProcessor do
  SAMPLE_ATTRIBUTES = {"title" => "Mot Hai Ba Yo", "bliindness_factor" => 1234 }

  describe ".perform #{SAMPLE_ATTRIBUTES}" do

    let(:new_hangover) { mock_model(Hangover).as_new_record.as_null_object }

    before do
      Hangover.stub(:new).and_return(new_hangover)
    end

    context "@queue" do
      it "should == :image_processor_queue" do
        ImageProcessor.instance_variable_get(:@queue).should == :image_processor_queue
      end
    end

    it "should build a new hangover from the parameters" do
      Hangover.should_receive(:new).with(SAMPLE_ATTRIBUTES)
      ImageProcessor.perform(SAMPLE_ATTRIBUTES)
    end

    it "should tell the hangover to process it's image and save" do
      new_hangover.should_receive(:save_and_process_image).with(:now => true)
      ImageProcessor.perform(SAMPLE_ATTRIBUTES)
    end
  end
end

