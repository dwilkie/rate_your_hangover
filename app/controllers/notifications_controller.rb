class NotificationsController < ApplicationController
  prepend_before_filter :mark_as_read, :only => :show
  prepend_before_filter :authenticate_user!

  def index
    @notifications = current_user.notifications
  end

  def show
  end

  private
    def mark_as_read
      @notification = current_user.notifications.find(params[:id])
      @notification.mark_as_read
    end

end

