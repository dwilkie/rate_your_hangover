class Hangover < ActiveRecord::Base

  attr_reader   :caption

  attr_accessible :title

  has_many :votes, :as => :voteable
  belongs_to :user

  EXTRA_SUMMARY_CATEGORIES = [:latest, :best]
  TIME_PERIODS = [:day, :week, :month, :year]
  MOUNT_AS = :image

  mount_uploader MOUNT_AS, ImageUploader

  validates :user, :title, :presence => true

  validates MOUNT_AS, :is_attached => true,
                      :is_uploaded => true,
                      :unique_filename => true,
                      :filename_format => true,
                      :remote_net_url_format => true

  def self.best
    order("votes_count DESC").first
  end

  def self.latest
    self.last
  end

  class << self
    TIME_PERIODS.each do |time_period|
      define_method("of_the_#{time_period}") do
        utc_time = Time.now.utc
        self.where{
          (created_at >= utc_time.send("beginning_of_#{time_period}")) &
          (created_at <= utc_time.send("end_of_#{time_period}"))
        }.best
      end
    end
  end

  def self.summary
    @@hangovers = []

    build_summary(EXTRA_SUMMARY_CATEGORIES.first)

    TIME_PERIODS.each do |time_period|
      build_summary("of_the_#{time_period}")
    end

    build_summary(EXTRA_SUMMARY_CATEGORIES.last)

    @@hangovers
  end

  def self.inventory(type = nil)
    summary
  end

  def build_caption(key)
    if persisted?
      hangover_title = title
      hangover_votes = votes_count
      owner = user.display_name
    else
      hangover_title = I18n.t("hangover.sober")
      hangover_votes = nil
      owner = nil
    end
    @caption = I18n.t(
      "hangover.caption",
      :title => hangover_title,
      :category => key,
      :votes => hangover_votes,
      :owner => owner
    )
  end

  def rated_by?(user)
    return nil if new_record?
    return false if user.nil?
    self.votes.by_user(user).any?
  end

  def save_and_process_image(options = {})
    valid?
    if no_errors = (errors.count == errors[MOUNT_AS].count)
      process_with_remote_image_net_url = has_remote_image_net_url?
      if options[:now]
        begin
          remote_url = process_with_remote_image_net_url ?
            remote_image_net_url : image.direct_fog_url(:with_path => true)
          self.remote_image_url = remote_url
        rescue StandardError => error
        else
          save!
        ensure
          if error
            subject = I18n.t(
              "notifications.upload_failed.subject",
            )
            message = I18n.t(
              "notifications.upload_failed.message",
              :allowed_file_types => image.extension_white_list.to_sentence
            )
            Notification.for_user!(user, :message => message, :subject => subject)
            raise unless error.is_a?(CarrierWave::ProcessingError)
          end
        end
      else
        virtual_attributes = process_with_remote_image_net_url ?
          {"remote_image_net_url" => remote_image_net_url} : {"key" => key}
        Resque.enqueue(
          ImageProcessor,
          attributes.merge(virtual_attributes),
          ["user_id"]
        )
      end
    end
    no_errors
  end

  def delete_upload(options = {})
    if options[:now]
      Fog::Storage.new(image.fog_credentials).directories.new(
        :key => send(MOUNT_AS).fog_directory, :public => send(MOUNT_AS).fog_public
      ).files.new(:key => key).destroy unless self.class.exists?(MOUNT_AS => send(MOUNT_AS).filename)
    else
      Resque.enqueue_in(24.hours, UploadGarbageCollector, :key => key) if send("has_#{MOUNT_AS}_upload?")
    end
  end

  private

  def self.build_summary(summary_category)
    hangover = self.send(summary_category) || self.new
    hangover.build_caption(summary_category)
    @@hangovers << hangover
  end
end

