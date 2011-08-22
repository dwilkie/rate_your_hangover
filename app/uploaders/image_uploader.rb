# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick
  include CarrierWaveDirect::Uploader

  def self.extension_white_list
    %w(jpg jpeg gif png)
  end

  version :thumb do
    process :resize_to_limit => [200, 200]
  end
end

