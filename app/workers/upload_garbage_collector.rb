class UploadGarbageCollector

  @queue = :upload_garbage_collector_queue

  def self.perform(hangover_attributes)
    Hangover.new(hangover_attributes).delete_upload(:now => true)
  end
end

