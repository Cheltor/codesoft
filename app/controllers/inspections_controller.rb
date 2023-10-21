class InspectionsController < ApplicationController
  before_action :set_address, except: [:all_inspections, :my_inspections, :my_unscheduled_inspections, :all_complaints, :my_complaints, :assign_inspector, :update_inspector]
  before_action :set_inspection, only: [:show, :edit, :update, :destroy]
  layout 'choices', only: [:new, :conduct]

  def all_inspections
    @inspections = Inspection.all.where.not(source: "Complaint").order(created_at: :desc)
  end

  def all_complaints
    @inspections = Inspection.where(source: "Complaint").order(created_at: :desc)
  end

  def my_complaints
    @inspections = Inspection.where(inspector: current_user, source: "Complaint").order(created_at: :desc)
  end

  def my_unscheduled_inspections
    @source = params[:source]
    @inspections = Inspection.where(inspector: current_user, scheduled_datetime: nil, status: nil).order(updated_at: :desc)

    case @source
    when "Complaint"
      @inspections = @inspections.where(source: "Complaint")
    when "Multifamily License"
      @inspections = @inspections.where(source: "Multifamily License")
    when "Business License"
      @inspections = @inspections.where(source: "Business License")
    when "Building/Dumpster/POD permit"
      @inspections = @inspections.where(source: "Building/Dumpster/POD permit")
    when "Donation Bin"
      @inspections = @inspections.where(source: "Donation Bin")
    when "Single Family License"
      @inspections = @inspections.where(source: "Single Family License")
    end
  end

  def my_inspections
    @scheduled_datetime = params[:scheduled_datetime]
    @inspections = Inspection.where(inspector: current_user).where.not(source: "Complaint").order(updated_at: :desc)

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
    # code_violations are both the inspection codes, the area codes, and the intersection of the two
    @code_violations = (@inspection.codes + @inspection.areas.map { |area| area.codes }.flatten).uniq
  end

  def new
    @inspection = @address.inspections.build
    @assignees = User.where(role: :ons)

    # pre filled forms 
    @inspection.source = params[:source] if params[:source].present?
    @inspection.description = params[:description] if params[:description].present?
    @inspeciton.contact_id = params[:contact_id] if params[:contact_id].present?
  end

  def conduct
    @inspection = Inspection.find(params[:id])
    @codes = Code.all
    @attachments = @inspection.attachments.all

    # Create code if they don't exist

  end

  def save_and_redirect_to_area_new
    @address = Address.find(params[:address_id])
    @inspection = @address.inspections.build(inspection_params)
    
    if @inspection.update(inspection_params)
      redirect_to new_address_inspection_area_path(@address, @inspection), notice: 'Inspection was successfully updated.'
    else
      render :conduct, notice: 'Inspection was not successfully updated.'
    end
  end

  def schedule
    @inspection = Inspection.find(params[:id])
    @scheduled_inspections = Inspection.where(inspector: current_user, status: nil)
                                        .where.not(scheduled_datetime: nil)
                                        .where.not(id: @inspection.id)
                                        .order(scheduled_datetime: :asc)
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

    if params[:inspection][:new_chapter].present?
      @code = Code.create(chapter: params[:inspection][:new_chapter], description: params[:inspection][:new_description], section: params[:inspection][:new_section], name: params[:inspection][:new_name])
        # Validate the code doesn't already exist by checking chapter and section combination
        if Code.where(chapter: params[:inspection][:new_chapter], section: params[:inspection][:new_section]).exists?
        end
      @inspection.codes << @code
    end

    # Check if scheduled_datetime is nil and source is not "Complaint"
    if @inspection.scheduled_datetime.nil? && @inspection.source != "Complaint"
      @inspection.scheduled_datetime = Time.now
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

  def assign_inspector
    
  end
  
  def update_inspector
    @inspection = Inspection.find(params[:id])
    @inspector = User.find(params[:inspection][:inspector_id])
  
    if @inspection.update(inspector: @inspector)
      redirect_to inspections_path, notice: 'Inspector assigned successfully.'
    else
      render :assign_inspector
    end
  end
  

  private

  def set_address
    @address = Address.find(params[:address_id])
  end

  def set_inspection
    @inspection = @address.inspections.find(params[:id])
  end

  def inspection_params
    params.require(:inspection).permit(:source, :status, :result, :description, :thoughts, :originator, :unit_id, :assignee_id, :inspector_id, :scheduled_datetime, :name, :email, :phone, :notes_area_1, :notes_area_2, :notes_area_3, :contact_id,:new_contact_name, :new_contact_email, :new_contact_phone, :new_chapter, :new_section, :new_name, :new_description, code_ids: [], intphotos: [], extphotos: [], photos: [], attachments: []).reject { |key, value| value.blank? }
  end

end