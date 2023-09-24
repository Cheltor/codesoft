class InspectionsController < ApplicationController
  before_action :set_address, except: [:all_inspections, :my_inspections]
  before_action :set_inspection, only: [:show, :edit, :update, :destroy]
  layout 'choices', only: [:conduct]

  def all_inspections
    @inspections = Inspection.all
  end

  def my_inspections
    @scheduled_datetime = params[:scheduled_datetime]
    @inspections = Inspection.where(inspector: current_user)

    case @scheduled_datetime
    when "scheduled"
      @inspections = @inspections.where.not(scheduled_datetime: nil).order(scheduled_datetime: :asc)
    when "unscheduled"
      @inspections = @inspections.where(scheduled_datetime: nil)
    else
      @scheduled_datetime = "all"
    end
  end

  def show
    @inspection = @address.inspections.find(params[:id])
    @attachments = @inspection.attachments.all
  end

  def new
    @inspection = @address.inspections.build
    @assignees = User.where(role: :ons)
  end

  def conduct
    @inspection = Inspection.find(params[:id])
    @codes = Code.all
  end

  def schedule
    @inspection = Inspection.find(params[:id])
  end

  def create
    @address = Address.find(params[:address_id])
    @inspection = @address.inspections.build(inspection_params)
    @inspection.originator = current_user if user_signed_in?

    if @inspection.save
      redirect_to @address, notice: 'Inspection was successfully created.'
    else
      render :new, notice: 'Inspection was not successfully created.'
    end
  end

  def edit
    @inspection = Inspection.find(params[:id])
    @assignees = User.where(role: :ons)
  end

  def update
    @inspection = Inspection.find(params[:id])
    puts "Params: #{params.inspect}"
    puts "Inspection Params: #{inspection_params.inspect}"
    if @inspection.update(inspection_params)
      redirect_to address_inspection_path(@address, @inspection), notice: 'Inspection was successfully updated.'
    else
      render :edit, notice: 'Inspection was not successfully updated.'
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
    params.require(:inspection).permit(:source, :status, :result, :description, :thoughts, :originator, :unit_id, :assignee_id, :inspector_id, :scheduled_datetime, :name, :email, :phone, :notes_area_1, :notes_area_2, :notes_area_3, code_ids: [], intphotos: [], extphotos: [], photos: [], attachments: []).reject { |key, value| value.blank? }
  end

end