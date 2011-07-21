require 'spec_helper'

describe UploadGarbageCollector do

  sample_attributes = {"bliindess_factor" => 1234}.freeze

  context "@queue" do
    it "should == :upload_garbage_collector_queue" do
      UploadGarbageCollector.instance_variable_get(
        :@queue
      ).should == :upload_garbage_collector_queue
    end
  end

  describe ".perform #{sample_attributes}" do

    let(:new_hangover) { mock_model(Hangover).as_new_record.as_null_object }

    before do
      Hangover.stub(:new).and_return(new_hangover)
    end

    it "should build a new hangover from the attributes" do
      Hangover.should_receive(:new).with(sample_attributes)
      subject.class.perform(sample_attributes)
    end

    it "should tell the hangover to delete the upload" do
      new_hangover.should_receive(:delete_upload).with(:now => true)
      subject.class.perform(sample_attributes)
    end
  end
end

