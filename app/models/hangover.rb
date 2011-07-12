class Hangover < ActiveRecord::Base

  attr_reader :caption
  attr_accessor :key

  attr_accessible :title, :key

  has_many :votes, :as => :voteable
  belongs_to :user

  EXTRA_SUMMARY_CATEGORIES = [:latest, :best]
  TIME_PERIODS = [:day, :week, :month, :year]
  MOUNT_AS = :image

  mount_uploader MOUNT_AS, ImageUploader

  validates :user, :title, :image, :presence => true
  validates :key, :presence => {:on => :create},
                  :format => ImageUploader.key(self, MOUNT_AS, :as => :regexp),
                  :allow_nil => true

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

  def save_and_process_image
    valid?
    if no_errors = (errors.count == errors[:image].count)
      Resque.enqueue(ImageProcessor, attributes, key)
    end
    no_errors
  end

  private

  def self.build_summary(summary_category)
    hangover = self.send(summary_category) || self.new
    hangover.build_caption(summary_category)
    @@hangovers << hangover
  end

end

