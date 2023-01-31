class ApplicationController < ActionController::Base
    before_action :set_ransack

    private

    def set_ransack
        @q = Address.ransack(params[:q])
    end
end
