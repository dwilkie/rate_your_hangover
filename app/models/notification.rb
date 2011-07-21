class Notification < ActiveRecord::Base
  belongs_to :user

  validates :user, :presence => true

  def self.unread
    where(:read_at => nil)
  end

end

