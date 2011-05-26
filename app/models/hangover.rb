class Hangover < ActiveRecord::Base

  attr_accessor :caption

  has_many :votes, :as => :voteable
  belongs_to :user

  validates :user, :title, :presence => true

end

