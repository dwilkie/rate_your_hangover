class NotificationsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @notifications = current_user.notifications
  end

  def show
    @notification = current_user.notifications.find(params[:id])
  end

end

