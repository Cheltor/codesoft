class AddressesController < ApplicationController
  layout 'choices', only: [:manage_contacts]

  def index
      @addresses = @q.result.where.not(streetnumb: nil)
      @violations = Violation.recent
      @comments = Comment.recent
  end
  
  def show
      @address = Address.find(params[:id])
      @address_citations = @address.violations.map(&:citations).flatten
      @address_photos = (
                          @address.violations.map(&:photos) + 
                          @address.comments.map(&:photos) + 
                          @address_citations.map(&:photos)
                        ).flatten.sort_by(&:created_at).reverse
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
    if params[:address][:contact_id].present?
      # If a contact is selected from the dropdown, associate it with the address
      selected_contact = Contact.find(params[:address][:contact_id])
      @address.contacts << selected_contact unless @address.contacts.include?(selected_contact)
    elsif !params[:address][:new_contact_name].blank?
      # If a new contact is being created, check if it already exists
      existing_contact = Contact.find_by(
        name: params[:address][:new_contact_name],
        email: params[:address][:new_contact_email]
      )

      if existing_contact
        @address.contacts << existing_contact unless @address.contacts.include?(existing_contact)
      else
        # Create a new contact and associate it with the address
        @contact = Contact.create(
          name: params[:address][:new_contact_name],
          email: params[:address][:new_contact_email],
          phone: params[:address][:new_contact_phone]
        )
        @address.contacts << @contact
      end
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
      params.require(:address).permit(:pid, :ownername, :owneraddress, :ownercity, :ownerstate, :ownerzip, :streetnumb, :streetname, :streettype, :landusecode, :zoning, :owneroccupiedin, :vacant, :absent, :premisezip, :combadd, :outstanding, contact_ids: [])
  end
  
end
