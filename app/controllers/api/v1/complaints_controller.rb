
class Api::V1::ComplaintsController < ActionController::Base
  def index
    @complaints = Inspection.all.where(source: "Complaint")
    render json: @complaints.map { |complaint| complaint.attributes.merge(address: complaint.address) }
  end

  def show
    @complaint = Complaint.find(params[:id])
    render json: @complaint
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