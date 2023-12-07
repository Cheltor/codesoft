class ApplicationController < ActionController::Base
    before_action :set_ransack
    before_action :authenticate_user!
    before_action :notifications

    private

    def set_ransack
        @q = Address.ransack(params[:q])
    end

    def notifications
        if user_signed_in?
            @notifications = current_user.notifications.where(read: false).order(created_at: :desc)
        else
            @notifications = []
        end
    end
end
