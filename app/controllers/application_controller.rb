class ApplicationController < ActionController::Base
  protect_from_forgery

  private

  def find_or_create_current_user
    user = current_user
    unless user
      user = User.create!
      user.remember_me!
      sign_in(user)
    end
    user
  end
end

