class ImageProcessor

  @queue = :image_processor_queue

  def self.perform(hangover_attributes)
    new_hangover = Hangover.new(hangover_attributes)
  end
end

