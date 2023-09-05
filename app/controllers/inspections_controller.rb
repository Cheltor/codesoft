class InspectionsController < ApplicationController
  before_action :set_address
  before_action :set_inspection, only: [:show, :edit, :update, :destroy]

  def index
    @inspections = Inspection.all
  end

  def show
    @inspection = @address.inspections.find(params[:id])
    @attachments = @inspection.attachments.all
  end

  def new
    @address = Address.find(params[:address_id])
    @inspection = @address.inspections.build
    @assignees = User.where(role: :ons)
  end

  def create
    @address = Address.find(params[:address_id])
    @inspection = @address.inspections.build(inspection_params)
    @inspection.originator = current_user if user_signed_in?
  
    if params[:inspection][:assignee].present?
      @inspection.assignee = User.find(params[:inspection][:assignee])
    end

    if @inspection.save
      redirect_to @address, notice: 'Inspection was successfully created.'
    else
      render :new
    end
  end

  def edit
    @inspection = Inspection.find(params[:id])
    @assignees = User.where(role: :ons)
  end

  def update
    @inspection = Inspection.find(params[:id])

    if @inspection.update(inspection_params)
      redirect_to address_inspection_path(@address, @inspection), notice: 'Inspection was successfully updated.'
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
    params.require(:inspection).permit(:source, :status, :result, :description, :thoughts, :originator, :unit_id, :assignee_id, :inspector_id, attachments: [])
  end

end