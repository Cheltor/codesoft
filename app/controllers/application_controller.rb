class ApplicationController < ActionController::Base
    before_action :set_ransack
    before_action :authenticate_user!

    private

    def set_ransack
        @q = Address.ransack(params[:q])
    end
end
