class Notification < ActiveRecord::Base
  belongs_to :user

  validates :user, :presence => true
  # String column in db
  validates :subject, :length => { :maximum => 255 }

  def self.unread
    where(:read_at => nil)
  end

  def self.for_user!(usr, options = {})
    notification = self.new
    notification.user = usr
    notification.message = options[:message]
    notification.subject = options[:subject]
    notification.save!
    notification
  end

  def read?
    read_at.present?
  end

  def mark_as_read
    self.update_attribute(:read_at, Time.now)
  end
end

