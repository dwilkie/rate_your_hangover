require 'carrierwave/test/matchers'

describe ImageUploader do
  include CarrierWave::Test::Matchers

  let(:hangover) { stub_model(Hangover).as_null_object }
  let(:uploader) { ImageUploader.new(hangover, :image) }

  before do
    uploader.store!(File.open(image_fixture_path))
  end

  context 'the thumb version' do
    it "should scale down a landscape image to fit within 200 by 200 pixels" do
      uploader.thumb.should be_no_larger_than(200, 200)
    end
  end
end

