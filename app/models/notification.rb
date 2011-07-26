class Notification < ActiveRecord::Base
  belongs_to :user

  validates :user, :presence => true

  def self.unread
    where(:read_at => nil)
  end

  def self.for_user!(usr, options = {})
    notification = self.new
    notification.user = usr
    notification.message = options[:message]
    notification.save!
    notification
  end

end

