class PermitsController < ApplicationController
  before_action :set_permit, only: [:show]

  def index
    @permits = Permit.all
  end

  def show
    @address = @permit.address
  end

  # Create a method for updating the paid attribute
  def paid
    @permit = Permit.find(params[:id])
    @permit.update_attribute(:paid, !@permit.paid)
    redirect_to permit_path(@permit)
  end

  # Create a method for updating the sent attribute
  def sent
    @permit = Permit.find(params[:id])
    @permit.update_attribute(:sent, !@permit.sent)
    redirect_to permit_path(@permit)
  end

  # Create a method for updating the revoked attribute
  def revoked
    @permit = Permit.find(params[:id])
    @permit.update_attribute(:revoked, !@permit.revoked)
    redirect_to permit_path(@permit)
  end

  # Create a method for updating the permit
  def update
    @permit = Permit.find(params[:id])
    if @permit.update(permit_params)
      redirect_to permit_path(@permit)
    else
      render :edit
    end
  end

  # Create a method for editing the permit
  def edit
    @permit = Permit.find(params[:id])
    @address = @permit.address
  end

  # Create a method for deleting the permit
  def destroy
    @permit = Permit.find(params[:id])
    @permit.destroy
    redirect_to permits_path
  end

  private
  
  def set_permit
    @permit = Permit.find(params[:id])
  end

  def permit_params
    params.require(:permit).permit(:address_id, :inspection_id, :sent, :revoked, :fiscal_year, :expiration_date, :permitnumber, :date_issued, :conditions, :paid)
  end
end
