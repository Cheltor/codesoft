class InspectionsController < ApplicationController
  before_action :set_address, except: [:all_inspections, :my_inspections]
  before_action :set_inspection, only: [:show, :edit, :update, :destroy]
  layout 'choices', only: [:new, :conduct]

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
    @code_violations = @inspection.codes
  end

  def new
    @inspection = @address.inspections.build
    @assignees = User.where(role: :ons)
  end

  def conduct
    @inspection = Inspection.find(params[:id])
    @codes = Code.all

    # Create code if they don't exist

  end

  def schedule
    @inspection = Inspection.find(params[:id])
  end

  def create
    @address = Address.find(params[:address_id])
    @inspection = @address.inspections.build(inspection_params)
    @inspection.originator = current_user if user_signed_in?
  
    if params[:inspection][:contact_id].present?
      # If a contact is selected from the dropdown, associate it with the inspection
      @inspection.contact_id = params[:inspection][:contact_id]
    elsif !params[:inspection][:new_contact_name].blank?
      # If a new contact is being created, check if it already exists
      existing_contact = Contact.find_by(
        name: params[:inspection][:new_contact_name],
        email: params[:inspection][:new_contact_email]
      )
  
      if existing_contact
        @inspection.contact = existing_contact
      else
        # Create a new contact and associate it with the inspection
        @contact = Contact.create(
          name: params[:inspection][:new_contact_name],
          email: params[:inspection][:new_contact_email],
          phone: params[:inspection][:new_contact_phone]
        )
        @inspection.contact = @contact
      end
    end
  
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

    if params[:inspection][:contact_id].blank? && !params[:inspection][:new_contact_name].blank?
      @contact = Contact.create(name: params[:inspection][:new_contact_name], email: params[:inspection][:new_contact_email], phone: params[:inspection][:new_contact_phone])
      @inspection.contact = @contact
    end

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
    params.require(:inspection).permit(:source, :status, :result, :description, :thoughts, :originator, :unit_id, :assignee_id, :inspector_id, :scheduled_datetime, :name, :email, :phone, :notes_area_1, :notes_area_2, :notes_area_3, :contact_id,:new_contact_name, :new_contact_email, :new_contact_phone, code_ids: [], intphotos: [], extphotos: [], photos: [], attachments: []).reject { |key, value| value.blank? }
  end

end