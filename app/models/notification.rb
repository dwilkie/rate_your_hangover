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

end

