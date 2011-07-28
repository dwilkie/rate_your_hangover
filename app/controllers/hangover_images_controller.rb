class HangoverImagesController < ApplicationController
  prepend_before_filter :authenticate_user!

  def new
    @image_uploader = ImageUploader.new(Hangover.new, :image)
    @image_uploader.success_action_redirect = new_hangover_url
  end
end

