class InspectionsController < ApplicationController
  before_action :set_address
  before_action :set_inspection, only: [:show, :edit, :update, :destroy]

  def index
    @inspections = Inspection.all
  end

  def show
    @inspection = @address.inspections.find(params[:id])
  end

  def new
    @address = Address.find(params[:address_id])
    @inspection = @address.inspections.build
  end

  def create
    @address = Address.find(params[:address_id])
    @inspection = @address.inspections.build(inspection_params)
    @inspection.originator = current_user

    if @inspection.save
      redirect_to @address, notice: 'Inspection was successfully created.'
    else
      render :new
    end
  end

  def edit
    @inspection = Inspection.find(params[:id])
  end

  def update
    @inspection = Inspection.find(params[:id])
    if @inspection.update(inspection_params)
      redirect_to @inspection
    else
      render :edit
    end
  end

  def destroy
    @inspection = Inspection.find(params[:id])
    @inspection.destroy
    redirect_to inspections_path
  end

  private

  def set_address
    @address = Address.find(params[:address_id])
  end

  def set_inspection
    @inspection = @address.inspections.find(params[:id])
  end

  def inspection_params
    params.require(:inspection).permit(:source, :status, :result, :description, :thoughts, :originator, :unit_id, attachments: [])
  end

end