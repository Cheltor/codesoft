class ViolationsController < ApplicationController
  before_action :set_address

  def new
    @violation = @address.violations.new
  end

  def create
    @violation = @address.violations.new(violation_params)

    if @violation.save
      redirect_to @address, notice: "Violation reported successfully."
    else
      render :new
    end
  end

  private

  def set_address
    @address = Address.find(params[:address_id])
  end

  def violation_params
    params.require(:violation).permit(:description, :status)
  end
end
