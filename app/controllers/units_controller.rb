class UnitsController < ApplicationController
  layout 'choices', only: [:manage_contacts]

  def index
    @address = Address.find(params[:address_id])
    @units = @address.units
  end

  def show
    @address = Address.find(params[:address_id])
    @unit = @address.units.find(params[:id])
    @violations = @unit.violations
    @address_citations = @unit.citations
    @inspections = @unit.inspections.where.not(source: "Complaint")
    @complaints = @inspections.where(source: "Complaint")
  
    violation_comments = @violations.flat_map(&:violation_comments)
    citation_comments = @violations.flat_map { |violation| violation.citations.flat_map(&:citation_comments) }
    @comments = []
    unit_comments = @unit.comments
  
    @comments = (violation_comments + citation_comments + unit_comments).sort_by(&:created_at).reverse
  
    @unit_photos = (@violations.map(&:photos) + @comments.map(&:photos) + @address_citations.map(&:photos)).flatten.sort_by(&:created_at).reverse
    timeline_items = (@violations + @comments + @address_citations + @inspections).sort_by(&:created_at).reverse
  
    # Paginate timeline_items
    page = params[:page] || 1
    per_page = 10 # or any number you prefer
    total_items = timeline_items.length
    @timeline_items = WillPaginate::Collection.create(page, per_page, total_items) do |pager|
      pager.replace timeline_items[pager.offset, pager.per_page].to_a
    end
  end
  
  def all_unit_comments
    @address = Address.find(params[:address_id])
    @unit = @address.units.find(params[:id])
    @comments = @unit.comments
    @violations = @unit.violations
    @address_citations = @unit.citations
    @inspections = @unit.inspections.where.not(source: "Complaint")
    @complaints = @inspections.where(source: "Complaint")

    violation_comments = @violations.flat_map(&:violation_comments)
    citation_comments = @violations.flat_map { |violation| violation.citations.flat_map(&:citation_comments) }
    @comments = []
    unit_comments = @unit.comments

    @comments = (violation_comments + citation_comments + unit_comments).sort_by(&:created_at).reverse

    @unit_photos = (@violations.map(&:photos) + @comments.map(&:photos) + @address_citations.map(&:photos)).flatten.sort_by(&:created_at).reverse

    
  end

  def all_unit_violations
    @address = Address.find(params[:address_id])
    @unit = @address.units.find(params[:id])
    @violations = @unit.violations.order(created_at: :desc)
    @status = params[:status]

    case @status
    when "current"
      @violations = @violations.where(status: :current)
    when "resolved"
      @violations = @violations.where(status: :resolved)
    end
  end

  def all_unit_citations
    @address = Address.find(params[:address_id])
    @unit = @address.units.find(params[:id])
    @citations = @unit.citations
  end

  def all_unit_inspections
    @address = Address.find(params[:address_id])
    @unit = @address.units.find(params[:id])
    @inspections = @unit.inspections.where.not(source: "Complaint")
  end

  def all_unit_complaints
    @address = Address.find(params[:address_id])
    @unit = @address.units.find(params[:id])
    @inspections = @unit.inspections.where(source: "Complaint")
  end

  def manage_contacts
    @unit = Unit.find(params[:id])
    @existing_contacts = Contact.all # This fetches all existing contacts for the dropdown
  
    if request.post?
      Rails.logger.debug("Received a POST request to manage_contacts")
      
      if params[:unit][:contact_ids].present?
        params[:unit][:contact_ids].each do |contact_id|
          selected_contact = Contact.find(contact_id)
          unless @unit.contacts.include?(selected_contact)
            @unit.contacts << selected_contact
            Rails.logger.debug("Added selected_contact with ID #{contact_id} to the unit")
          end
        end
      elsif !params[:unit][:new_contact_name].blank?
        # If a new contact is being created, check if it already exists
        existing_contact = Contact.find_by(
          name: params[:unit][:new_contact_name],
          email: params[:unit][:new_contact_email]
        )
  
        if existing_contact
          @unit.contacts << existing_contact
          Rails.logger.debug("Added existing_contact to the unit")
        else
          # Create a new contact and associate it with the unit
          @contact = Contact.create(
            name: params[:unit][:new_contact_name],
            email: params[:unit][:new_contact_email],
            phone: params[:unit][:new_contact_phone]
          )
          @unit.contacts << @contact
          Rails.logger.debug("Created and added a new contact to the unit")
        end
      else
        Rails.logger.debug("No contact information provided in the form")
      end
  
      redirect_to address_unit_path(@unit.address, @unit), notice: 'Contacts were successfully added to the unit.'
    end
  end

  def remove_contact
    @unit = Unit.find(params[:id])
    @contact = Contact.find(params[:contact_id])

    if @unit.contacts.include?(@contact)
      @unit.contacts.delete(@contact)
      redirect_to address_unit_path(@unit.address, @unit), notice: 'Contact was successfully removed from the unit.'
    else
      redirect_to address_unit_path(@unit.address, @unit), notice: 'Contact was not removed.'
    end
  end

  def new
    @address = Address.find(params[:address_id])
  end

  def create
    @address = Address.find(params[:address_id])
    @unit = @address.units.build(unit_params)

    if @unit.save
      redirect_to @address, notice: 'Unit was successfully added.'
    else
      redirect_to address_path(@address), notice: 'The unit already exists.'
    end
  end

  def edit
    @address = Address.find(params[:address_id])
    @unit = @address.units.find(params[:id])
  end

  def update
    @address = Address.find(params[:address_id])
    @unit = @address.units.find(params[:id])

    if @unit.update(unit_params)
      redirect_to @address, notice: 'Unit was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @address = Address.find(params[:address_id])
    @unit = @address.units.find(params[:id])
    @unit.destroy
    redirect_to @address, notice: 'Unit was successfully removed.'
  end

  private

  def unit_params
    params.require(:unit).permit(:number)
  end
end
