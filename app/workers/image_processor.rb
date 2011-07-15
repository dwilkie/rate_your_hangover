class ImageProcessor

  @queue = :image_processor_queue

  def self.perform(hangover_attributes)
    Hangover.new(hangover_attributes).save_and_process_image(:now => true)
  end
end

