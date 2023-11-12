class AddressesController < ApplicationController
  layout 'choices', only: [:manage_contacts]

  def index
      @addresses = @q.result.where.not(streetnumb: nil)
      @violations = Violation.recent
      @comments = Comment.recent
  end
  
  def show
    @address = Address.find(params[:id])
    @address_citations = @address.violations.map(&:citations).flatten.sort_by(&:deadline).reverse
    tl_address_citations = @address.violations.flat_map(&:citations).sort_by(&:deadline).reverse

    @address_photos = (
                        @address.violations.map(&:photos) + 
                        @address.comments.map(&:photos) + 
                        @address_citations.map(&:photos)
                      ).flatten.sort_by(&:created_at).reverse

    @timeline_items = (@address.violations + @address.comments + @address_citations + @address.inspections).sort_by(&:created_at).reverse

    @address_violations = @address.violations.where(violations: { status: :current })
                                              .select { |violation| violation.deadline_date <= Date.tomorrow }
                                              .reject { |violation| violation.citations.where(citations: { status: [:unpaid, "pending trial"] }).any? { |citation| citation.deadline >= Date.tomorrow }}
                                              .any?
    tl_address_violations = @address.violations

    @address_inspections = @address.inspections.where(status: nil).where.not(source: "Complaint").any?
    tl_address_inspections = @address.inspections

    # Check if the address has any citations
    @address_citations_count = @address.violations.map(&:citations).flatten.select { |citation| citation.status.in?([:unpaid, "pending trial"]) }.count > 0

    # Check if the address's updated_at is not today
    not_updated_today = !@address.updated_at.today?

    # Combine these checks
    @is_priority_address = (@address_violations ||@address_citations_count ||@address_inspections ) && not_updated_today

    # Address complaints
    @complaints = @address.inspections.where(source: "Complaint")
    
    # fetching all comments
    violation_comments = @address.violations.flat_map(&:violation_comments)
    citation_comments = @address.violations.flat_map { |violation| violation.citations.flat_map(&:citation_comments) }
    address_comments = @address.comments

    # Combine all comments
    tl_comments = (violation_comments + citation_comments + address_comments).sort_by(&:created_at).reverse

    # Timeline
    @timeline_items = (
      tl_address_violations.to_a + 
      tl_comments.to_a + 
      tl_address_citations + 
      tl_address_inspections.to_a
    ).sort_by(&:created_at).reverse
  
  end
  
  def address_name
    @address = Address.find(params[:id])
  end

  def violist
      @status = params[:status]
      @violations = Violation.all
    
      case @status
      when "current"
        @violations = @violations.where(status: :current)
      when "resolved"
        @violations = @violations.where(status: :resolved)
      when "closed"
        @violations = @violations.where(status: :closed)
      else
        @status = "all"
      end
    
      @violations = @violations.order(created_at: :desc)
  end

  def mark_outstanding
    @address = Address.find(params[:id])

    if @address.update(outstanding: !@address.outstanding)
      respond_to do |format|
        format.turbo_stream
      end
    end
  end

  def my_violations
      @status = params[:status]
      @violations = Violation.where(user: current_user)
    
      case @status
      when "current"
        @violations = @violations.where(status: :current)
      when "resolved"
        @violations = @violations.where(status: :resolved)
      when "closed"
        @violations = @violations.where(status: :closed)
      else
        @status = "all"
      end
    
      @violations = @violations.where(user: current_user).order(created_at: :desc)
    end

  def search
      @search = Address.ransack(params[:q])
      @addresses = @search.result
  end
  
  def edit
    @address = Address.find(params[:id])
  end

  def update
    @address = Address.find(params[:id])
      if @address.update(address_params)
          redirect_to @address, notice: 'Address was successfully updated.'
      else
          render :edit
      end
  end

  # app/controllers/addresses_controller.rb
  def manage_contacts
    @address = Address.find(params[:id])
    @existing_contacts = Contact.all # This fetches all existing contacts for the dropdown
  
    if request.post?
      Rails.logger.debug("Received a POST request to manage_contacts")
      
      if params[:address][:contact_ids].present?
        params[:address][:contact_ids].each do |contact_id|
          selected_contact = Contact.find(contact_id)
          unless @address.contacts.include?(selected_contact)
            @address.contacts << selected_contact
            Rails.logger.debug("Added selected_contact with ID #{contact_id} to the address")
          end
        end
      elsif !params[:address][:new_contact_name].blank?
        # If a new contact is being created, check if it already exists
        existing_contact = Contact.find_by(
          name: params[:address][:new_contact_name],
          email: params[:address][:new_contact_email]
        )
  
        if existing_contact
          @address.contacts << existing_contact
          Rails.logger.debug("Added existing_contact to the address")
        else
          # Create a new contact and associate it with the address
          @contact = Contact.create(
            name: params[:address][:new_contact_name],
            email: params[:address][:new_contact_email],
            phone: params[:address][:new_contact_phone]
          )
          @address.contacts << @contact
          Rails.logger.debug("Created and added a new contact to the address")
        end
      else
        Rails.logger.debug("No contact information provided in the form")
      end
  
      redirect_to address_path(@address), notice: 'Contacts were successfully managed.'
    end
  end
  



  def new
      @address = Address.new(premisezip: "20737")
  end

  def create
      @address = Address.new(address_params)

      if @address.save
          redirect_to @address, notice: 'Address was successfully created.'
      else
          render :new
      end
  end

  private

  def address_params
      params.require(:address).permit(:pid, :ownername, :owneraddress, :ownercity, :ownerstate, :ownerzip, :streetnumb, :streetname, :streettype, :landusecode, :zoning, :owneroccupiedin, :vacant, :absent, :premisezip, :combadd, :outstanding, :property_name, contact_ids: [])
  end

  def current_page
    params[:page] || 1
  end
  
  def per_page
    10 # or any other number of items you want to display per page
  end
  
end
