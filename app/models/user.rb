class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  has_many :votes
  has_many :hangovers

  validates :display_name, :presence => true

  def self.with_ip(ip)
    self.where{
      (current_sign_in_ip == ip ) | (last_sign_in_ip == ip)
    }
  end
end

