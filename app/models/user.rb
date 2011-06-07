class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  has_many :votes
  has_many :hangovers

  validates :display_name, :presence => true, :if => :password_required?

  def self.with_ip(ip)
    self.where{
      (current_sign_in_ip == ip ) | (last_sign_in_ip == ip)
    }
  end

  protected

  # Checks whether a password is needed or not. For validations only.
  # Passwords are always required if an there's an email, or if the password
  # or confirmation are being set somewhere.
  def password_required?
    email.present? || !password.nil? || !password_confirmation.nil?
  end

  def email_required?
    false
  end

end

