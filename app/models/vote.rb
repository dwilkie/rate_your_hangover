class Vote < ActiveRecord::Base
  belongs_to :voteable, :polymorphic => true, :counter_cache => true
  belongs_to :user

  validates :voteable, :presence => true

  validates :user,
            :presence => true

  validates :user_id,
            :uniqueness => {:scope => [:voteable_id, :voteable_type]}
end

