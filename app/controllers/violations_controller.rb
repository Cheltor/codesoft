class ViolationsController < ApplicationController
  before_action :set_address
  before_action :set_violation, only: [:resolve]
  layout 'new_violation', only: [:new]

  def new
    @violation = @address.violations.new
  end

  def create
    @violation = @address.violations.new(violation_params)
    @violation.user = current_user
    @violation.code_ids = params[:code_ids]

    if @violation.save
      redirect_to @address, notice: "Violation reported successfully."
    else
      render :new
    end
  end

  def resolve
    if @violation.update(status: :resolved)
      redirect_to @address, notice: "Violation resolved successfully."
    else
      redirect_to @address, alert: "Failed to resolve violation."
    end
  end

  private

  def set_address
    @address = Address.find(params[:address_id])
  end

  def violation_params
    params.require(:violation).permit(:description, :deadline, :status, photos: [])
  end

  def set_violation
    @violation = @address.violations.find(params[:id])
  end
end
