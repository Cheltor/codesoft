
class Api::V1::ViolationsController < ActionController::Base
  def index
    @violations = Violation.order(created_at: :desc)
    render json: @violations.map { |violation| violation.attributes.merge(address: violation.address) }
  end

  def show
    @violation = Violation.find(params[:id])
    render json: @violation
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