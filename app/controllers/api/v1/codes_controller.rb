
class Api::V1::CodesController < ActionController::Base
  def index
    @codes = Code.all
    render json: @codes
  end

  def show
    @code = Code.find(params[:id])
    render json: @code
  end

  def create
    # Your code for creating a new business goes here
  end

  def update
    # Your code for updating an existing business goes here
  end

  def destroy
    # Your code for deleting a business goes here
  end
end