class Api::V1::ApiBaseController < ActionController::API
    include DeviseTokenAuth::Concerns::SetUserByToken
    before_action :authenticate_user!
end