class ApplicationController < ActionController::Base
  protect_from_forgery

  private

  def current_user
    user = super
    unless user
      user = User.create!
      user.remember_me!
      sign_in(user)
    end
    user
  end
end

