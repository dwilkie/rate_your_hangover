# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick
  include CarrierWaveDirect::Uploader

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def url_scheme_white_list
    %w(http https)
  end

  version :thumb do
    process :resize_to_limit => [200, 200]
  end
end

