class PermitsController < ApplicationController
  before_action :set_permit, only: [:show]

  def index
    @permits = Permit.order(created_at: :desc).paginate(page: params[:page], per_page: 10)
  end

  def show
    @address = @permit.address
  end

  private
  
  def set_permit
    @permit = Permit.find(params[:id])
  end

  def permit_params
    params.require(:permit).permit(:address_id, :inspection_id, :sent, :revoked, :fiscal_year, :expiration_date, :permitnumber, :date_issued, :conditions, :paid)
  end
end
