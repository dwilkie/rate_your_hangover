class Hangover < ActiveRecord::Base

  attr_reader :caption

  has_many :votes, :as => :voteable
  belongs_to :user

  validates :user, :title, :presence => true

  EXTRA_SUMMARY_CATEGORIES = ["Latest Hangover", "Best Hangover"]
  TIME_PERIODS = [:day, :week, :month, :year]

  def self.of_all_time
    order("votes_count DESC").first
  end

  class << self
    TIME_PERIODS.each do |time_period|
      define_method("of_the_#{time_period}") do
        utc_time = Time.now.utc
        self.where{
          (created_at >= utc_time.send("beginning_of_#{time_period}")) &
          (created_at <= utc_time.send("end_of_#{time_period}"))
        }.of_all_time
      end
    end
  end

  def self.summary
    @@hangovers = []

    build_summary(:last, EXTRA_SUMMARY_CATEGORIES.first)

    TIME_PERIODS.each do |time_period|
      build_summary(
        "of_the_#{time_period}",
        time_period
      )
    end

    build_summary(:of_all_time, EXTRA_SUMMARY_CATEGORIES.last)

    @@hangovers
  end

  def self.inventory(type = nil)
    summary
  end

  def build_caption(pretext)
      pretext = "Hangover of the #{pretext.to_s.titleize}" if TIME_PERIODS.include?(pretext)
    @caption = "#{pretext} - \"#{title}\""
  end

  private

  def self.build_summary(summary_method, caption)
    hangover = self.send(summary_method)
    if hangover
      hangover.build_caption(caption)
      @@hangovers << hangover
    end
  end

end

