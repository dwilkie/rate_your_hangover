class Hangover < ActiveRecord::Base

  # Validations
  class UniqueFilenameValidator < ActiveModel::EachValidator
    # implement the method called during validation
    def validate_each(record, attribute, value)
      if record.class.where(options[:for] => record.send(options[:for]).filename).exists?
        record.errors.add(attribute, :taken, options.except(:for).merge(:value => value))
      end
    end
  end

  attr_reader   :caption

  attr_accessible :title, :key, :remote_image_net_url

  has_many :votes, :as => :voteable
  belongs_to :user

  EXTRA_SUMMARY_CATEGORIES = [:latest, :best]
  TIME_PERIODS = [:day, :week, :month, :year]
  ALLOWED_URL_SCHEMES = %w{http https}
  MOUNT_AS = :image

  mount_uploader MOUNT_AS, ImageUploader

  validates :user, :title, MOUNT_AS, :presence => true

  validates :remote_image_net_url,
            :presence => { :unless => :has_upload?, :on => :create },
            :format => {
              :with => URI.regexp(ALLOWED_URL_SCHEMES),
              :allowed_types => ALLOWED_URL_SCHEMES.to_sentence
              },
            :allow_nil => true

  # Need to have two separate validations here so cannot declare in the same validates method
  # since the second format will override the first one

  validates :remote_image_net_url,
            :format => {
              :with => /#{ImageUploader.allowed_file_types(:as => :regexp_string)}\z/,
              :allowed_types => ImageUploader.allowed_file_types(:as => :sentence)
            },
            :allow_nil => true

  validates :key, :unique_filename => { :for => MOUNT_AS },
                  :format => {
                    :with => ImageUploader.key(
                      :model_class => self, :mounted_as => MOUNT_AS, :as => :regexp
                    ),
                    :allowed_types => ImageUploader.allowed_file_types(
                      :as => :sentence
                    )
                  }, :unless => :has_remote_image_net_url?, :on => :create

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

  def key
    send(MOUNT_AS).key
  end

  def key=(k)
    send(MOUNT_AS).key = k
  end

  def remote_image_net_url
    send(MOUNT_AS).remote_net_url
  end

  def remote_image_net_url=(url)
    send(MOUNT_AS).remote_net_url = url
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

  def has_upload?
    send(MOUNT_AS).has_key?
  end

  def upload_path_valid?
    if has_upload?
      valid?
      key_errors = errors[:key]
      errors.clear
      key_errors.each do |key_error|
        errors.add(:key, key_error)
      end
      errors.empty?
    else
      true
    end
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
              :allowed_file_types => ImageUploader.allowed_file_types(:as_sentence => true)
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
        :key => image.fog_directory, :public => image.fog_public
      ).files.new(:key => key).destroy unless self.class.exists?(MOUNT_AS => send(MOUNT_AS).filename)
    else
      Resque.enqueue_in(24.hours, UploadGarbageCollector, :key => key) if has_upload?
    end
  end

  private

  def self.build_summary(summary_category)
    hangover = self.send(summary_category) || self.new
    hangover.build_caption(summary_category)
    @@hangovers << hangover
  end

  def has_remote_image_net_url?
    remote_image_net_url.present?
  end

end

