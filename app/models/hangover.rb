class Hangover < ActiveRecord::Base
  has_many :votes, :as => :voteable
  belongs_to :user

  validates :user, :title, :presence => true
end

