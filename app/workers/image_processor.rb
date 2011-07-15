class ImageProcessor

  @queue = :image_processor_queue

  def self.perform(hangover_attributes, explicit_attributes = [])
    hangover = Hangover.new(hangover_attributes)
    explicit_attributes.each do |explicit_attribute|
      hangover.send("#{explicit_attribute}=", hangover_attributes[explicit_attribute])
    end
    hangover.save_and_process_image(:now => true)
  end
end

