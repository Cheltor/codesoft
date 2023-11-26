
class Api::V1::ContactsController < ActionController::Base
  def index
    @contacts = Contact.all
    render json: @contacts
  end

  def show
    @contact = Contact.find(params[:id])
    render json: @contact
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