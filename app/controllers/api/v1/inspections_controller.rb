
class Api::V1::InspectionsController < ActionController::Base
  def index
    @inspections = Inspection.all
    render json: @inspections.map { |inspection| inspection.attributes.merge(address: inspection.address) }
  end

  def show
    @inspection = Inspection.find(params[:id])
    render json: @inspection
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