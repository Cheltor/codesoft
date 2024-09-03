class InspectionsController < ApplicationController
  before_action :set_address, except: [:all_inspections, :my_inspections, :my_unscheduled_inspections, :all_complaints, :my_complaints, :assign_inspector, :update_inspector, :create_complaint, :new_complaint, :create_permit_inspection, :new_permit_inspection, :create_license_inspection, :new_license_inspection, :unassigned_inspections, :assign_inspection, :inspection_calendar, :reassign_inspection, :mark_as_paid, :mark_as_not_paid, :create_unit]
  before_action :set_inspection, only: [:show, :edit, :update, :destroy]
  layout 'choices', only: [:conduct, :new, :new_complaint, :new_permit_inspection, :new_license_inspection]

  def all_inspections
    @inspections = Inspection.all.where.not(source: "Complaint").order(created_at: :desc)
    @inspector = params[:inspector]
    @status = params[:status]
    @source = params[:source]

    case @inspector
    when "Unassigned"
      @inspections = @inspections.where(inspector_id: nil)
    when "My Inspections"
      @inspections = @inspections.where(inspector: current_user)
    when "My Unscheduled"
      @inspections = @inspections.where(inspector: current_user, scheduled_datetime: nil)
    end

    case @status
    when "Unsatisfactory"
      @inspections = @inspections.where(status: "Unsatisfactory")
    when "Satisfactory"
      @inspections = @inspections.where(status: "Satisfactory")
    when "Pending" # Make sure this matches the string passed in the link
      @inspections = @inspections.where(status: nil)
    end

    case @source
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

    @inspections = @inspections.paginate(page: params[:page], per_page: 10)
  end

  def all_complaints
    @inspections = Inspection.where(source: "Complaint").order(created_at: :desc)
    @inspector = params[:inspector]
    @status = params[:status]
  
    case @inspector
    when "My Complaints"
      @inspections = @inspections.where(inspector: current_user)
    when "Unassigned"
      @inspections = @inspections.where(inspector_id: nil)
    end
  
    case @status
    when "Unsatisfactory"
      @inspections = @inspections.where(status: "Unsatisfactory")
    when "Satisfactory"
      @inspections = @inspections.where(status: "Satisfactory")
    when "Pending" # Make sure this matches the string passed in the link
      @inspections = @inspections.where(status: nil)
    end
  
    @inspections = @inspections.paginate(page: params[:page], per_page: 10)
  end
  
  def inspection_calendar
    @user = current_user
    start_of_week = Date.today.beginning_of_week
    end_of_week = Date.today.end_of_week
  
    # Initialize @inspections_by_day with each day of the week as keys and empty arrays as values
    @inspections_by_day = {
      'Monday'    => [],
      'Tuesday'   => [],
      'Wednesday' => [],
      'Thursday'  => [],
      'Friday'    => [],
      'Saturday'  => [],
      'Sunday'    => []
    }
  
    # Initialize @inspections_this_week to count the number of inspections
    @inspections_this_week = 0
  
    # Fetch inspections for the current user within the current week
    Inspection.where(inspector: @user, status: nil)
              .where(scheduled_datetime: start_of_week..end_of_week)
              .each do |inspection|
      if inspection.scheduled_datetime
        day_of_week = inspection.scheduled_datetime.strftime('%A')
        @inspections_by_day[day_of_week] << inspection
        @inspections_this_week += 1
      end
    end

    @inspections_by_day.each do |day, inspections|
      @inspections_by_day[day] = inspections.sort_by(&:scheduled_datetime)
    end
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
    @inspections = @inspections.paginate(page: params[:page], per_page: 10)

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

    @inspections = @inspections.paginate(page: params[:page], per_page: 10)
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
    @inspection.contact_id = params[:contact_id] if params[:contact_id].present?
    @unit = Unit.find(params[:unit_id]) if params[:unit_id].present?

    if params[:business_id]
      business = Business.find(params[:business_id])
      @inspection.business_id = business.id
      @inspection.description = business.business_name_and_trading_name
    end
  end

  def conduct
    @inspection = Inspection.find(params[:id])
    @codes = Code.all
    @attachments = @inspection.attachments.all
  
    if @inspection.areas.any?
      @inspected_units = @inspection.areas.map { |area| area.unit }.uniq.sort_by { |unit| unit.number }
    else
      @inspected_units = []
    end
  
    if @address&.units&.any?
      @uninspected_units = (@address.units - @inspected_units).sort_by { |unit| unit.number }
    else
      @uninspected_units = []
    end
  end

  def create_unit
    # Ensure params[:inspection_id] is not nil
    if params[:inspection_id].nil?
      redirect_back(fallback_location: inspections_path, notice: 'Inspection ID is missing.')
      return
    end

    @inspection = Inspection.find_by(id: params[:inspection_id])
    if @inspection.nil?
      redirect_back(fallback_location: inspections_path, notice: 'Inspection not found.')
      return
    end

    # Creating a new unit associated with the address
    @unit = Unit.new(unit_params)
    
    if @unit.save
      redirect_to new_address_inspection_area_path(@inspection.address, @inspection, unit_id: @unit.id), notice: 'Unit was successfully created.'
    else
      redirect_back(fallback_location: inspections_path, notice: 'Unit was not successfully created.')
    end
  end

  def new_license_inspection
    @inspection = Inspection.new
    @assignees = User.where(role: :ons)
  end

  def create_license_inspection
    @inspection = Inspection.new(inspection_params)

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
      redirect_to all_inspections_path, notice: 'Inspection request was successfully created.'
    else
      render :new_license_inspection
    end
  end

  def unassigned_inspections
    @inspections = Inspection.where(inspector_id: nil).order(created_at: :desc)
  end

  def new_permit_inspection
    @inspection = Inspection.new
    @assignees = User.where(role: :ons)
    @inspection.source = "Building/Dumpster/POD permit"
  end

  def create_permit_inspection
    @inspection = Inspection.new(inspection_params)

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
      redirect_to all_inspections_path, notice: 'Inspection request was successfully created.'
    else
      render :new_permit_inspection
    end
  end
  
  def new_complaint
    @inspection = Inspection.new
    @assignees = User.where(role: :ons)
    @inspection.source = "Complaint"
  end

  def create_complaint
    @inspection = Inspection.new(inspection_params)
    @inspection.current_user = current_user

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
      redirect_to all_complaints_path, notice: 'Inspection request was successfully created.'
    else
      render :new_complaint
    end
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
      redirect_to @address, notice: 'Inspection request was successfully created.'
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
    @inspection.current_user = current_user

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
      if @inspection.source == "Complaint" && @inspection.status == "Unsatisfactory"
        flash[:code_ids] = @inspection.code_ids
        redirect_to new_address_violation_path(@address, @inspection, code_ids: @inspection.code_ids.join(',')), notice: 'Inspection was successfully updated.'
      elsif @inspection.source == "Business license" && @inspection.status == "Satisfactory"
        redirect_to create_business_license_address_inspection_path(@address, @inspection)
      elsif @inspection.source == "Single Family License" && @inspection.status == "Satisfactory"
        redirect_to create_single_family_license_address_inspection_path(@address, @inspection)
      elsif @inspection.source == "Multifamily License" && @inspection.status == "Satisfactory"
        redirect_to create_multifamily_license_address_inspection_path(@address, @inspection)
      else
        redirect_to address_inspection_path(@address, @inspection), notice: 'Inspection was successfully updated.'
      end
    else
      render :conduct, notice: 'Inspection was not successfully updated.'
    end
  end

  def destroy
    @inspection = Inspection.find(params[:id])
    @inspection.destroy
    redirect_to all_inspections_path
  end

  def assign_inspection
    @inspection = Inspection.find(params[:id])
    @assignees = User.where(role: :ons)
  end
  
  def update_inspector
    @inspection = Inspection.find(params[:id])
    @inspector = User.find(params[:inspection][:inspector_id])
  
    if @inspection.update(inspector: @inspector)
      redirect_to unassigned_inspections_path, notice: 'Inspector assigned successfully.'
    else
      render :assign_inspection, notice: 'Inspector was not successfully assigned.'
    end
  end  

  def create_single_family_license
    @inspection = Inspection.find(params[:id])
    @address = Address.find(@inspection.address_id)

    # Check if a license already exists for this inspection
    
    if @inspection.license
      # Redirect to the license page or display an appropriate message
      return
    end

    # Create a new license object
    @license = License.new(inspection: @inspection)

    # Set the license type
    @license.license_type = :single_family

    if @license.save
      redirect_to license_path(@license)
    else
      # Handle the case when license creation fails
      # Redirect to an appropriate page or display an error message
    end
  end

  def create_business_license
    @inspection = Inspection.find(params[:id])
    @business = Business.find(@inspection.business_id)
    @address = @business.address

    # Check if a license already exists for this inspection
    if @inspection.license
      # Redirect to the license page or display an appropriate message
      return
    end

    # Create a new license object
    @license = License.new(inspection: @inspection, business: @business)

    # Set the license type
    @license.license_type = :business

    if @license.save
      redirect_to license_path(@license)
    else
      # Handle the case when license creation fails
      # Redirect to an appropriate page or display an error message
    end
  end

  def create_multifamily_license
    @inspection = Inspection.find(params[:id])
    @address = Address.find(@inspection.address_id)

    # Check if a license already exists for this inspection
    if @inspection.license
      # Redirect to the license page or display an appropriate message
      return
    end

    # Create a new license object
    @license = License.new(inspection: @inspection)

    # Set the license type
    @license.license_type = :multifamily

    if @license.save
      redirect_to license_path(@license)
    else
      # Handle the case when license creation fails
      # Redirect to an appropriate page or display an error message
    end
  end

  def mark_as_paid
    @inspection = Inspection.find(params[:id])
    @inspection.update(paid: true)
    redirect_to address_inspection_path(@inspection)
  end

  def mark_as_not_paid
    @inspection = Inspection.find(params[:id])
    @inspection.update(paid: false)
    redirect_to address_inspection_path(@inspection)
  end


  private

  def set_address
    @address = Address.find(params[:address_id])
  end

  def set_inspection
    @inspection = @address.inspections.find(params[:id])
  end

  def inspection_params
    params.require(:inspection).permit(:paid, :start_time, :address_id, :source, :business_id, :status, :result, :description, :thoughts, :originator, :unit_id, :assignee_id, :inspector_id, :scheduled_datetime, :name, :email, :phone, :notes_area_1, :notes_area_2, :notes_area_3, :contact_id,:new_contact_name, :new_contact_email, :new_contact_phone, :new_chapter, :new_section, :new_name, :new_description, :confirmed, code_ids: [], intphotos: [], extphotos: [], photos: [], attachments: []).reject { |key, value| value.blank? }
  end

end