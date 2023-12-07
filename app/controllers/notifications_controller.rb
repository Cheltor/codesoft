class NotificationsController < ApplicationController
  def mark_as_read
    notification = Notification.find(params[:id])
    notification.update(read: true)
  
    redirect_to params[:redirect_url] || default_path
  end

  private

  def default_path
    root_path
  end
end