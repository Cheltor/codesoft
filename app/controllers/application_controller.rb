class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    protect_from_forgery with: :null_session, if: -> { request.format.json? }
    before_action :set_ransack
    before_action :authenticate_user!
    before_action :notifications
    before_action :set_csrf_cookie
    respond_to :html, :json

    private

    def set_csrf_cookie
        cookies["CSRF-TOKEN"] = form_authenticity_token if protect_against_forgery?
    end

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
