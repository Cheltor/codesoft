
class Api::V1::BusinessesController < ActionController::Base
  def index
    @businesses = Business.all
    render json: @businesses.map { |business| business.attributes.merge(address: business.address) }
  end

  def show
    @business = Business.find(params[:id])
    render json: @business
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

