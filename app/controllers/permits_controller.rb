class PermitsController < ApplicationController
  before_action :set_permit, only: [:show]
  before_action :authenticate_user!

  def index
    @permits = Permit.all
  end

  def show
  end

  private
  
  def set_permit
    @permit = Permit.find(params[:id])
  end

  def permit_params
    params.require(:permit).permit(:address_id, :inspection_id, :sent, :revoked, :fiscal_year, :expiration_date, :permitnumber, :date_issued, :conditions, :paid)
  end
end
