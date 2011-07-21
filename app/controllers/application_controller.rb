class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_for_new_notifications

  private

  def find_or_create_current_user
    user = current_user
    unless user
      if User.with_ip(request.remote_ip).empty?
        user = User.new
        user.save!(:validate => false)
        user.remember_me!
        sign_in(user)
      end
    end
    user
  end

  def check_for_new_notifications
    if user_signed_in?
      @unread_notification_count = current_user.notifications.unread.count
     end
  end
end

