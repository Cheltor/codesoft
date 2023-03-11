class ViolationsController < ApplicationController
  before_action :set_address
  before_action :set_violation, only: [:resolve, :extender, :update, :edit]
  layout 'new_violation', only: [:new, :edit]

  def new
    @violation = @address.violations.new
  end

  def update
    @new_violation = @address.violations.new(violation_params)
    @new_violation.user = current_user

    if @new_violation.save
      @violation.update(status: :resolved)
      redirect_to address_path(@address), notice: "Violation created successfully"
    else
      render :edit
    end
  end

  def edit
  end

  def create
    @violation = @address.violations.new(violation_params)
    @violation.user = current_user

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

  def extender
    days = params[:days].to_i
    @violation.extend += days
    if @violation.save
      @violation.reload
      redirect_to @address, notice: "Extended by #{days} days"
    else
      redirect_to @address, alert: "Failed to extend"
    end
  end

  private

  def set_address
    @address = Address.find(params[:address_id])
  end

  def violation_params
    params.require(:violation).permit(:description, :deadline, :status, :extend, :violation_type, photos: [], code_ids: [])
  end

  def set_violation
    @violation = @address.violations.find(params[:id])
  end
end
