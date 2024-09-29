class BusinessesController < ApplicationController
  layout 'choices', only: [:new, :edit, :new_business]
  before_action :authenticate_user!

  def index
    @business_q = Business.ransack(params[:q])
    @businesses = @business_q.result(distinct: true).order(created_at: :desc)

    case params[:licensed]
    when '1'
      @businesses = @businesses.joins(:licenses).where('licenses.expiration_date > ?', Date.today).distinct
    when '0'
      @businesses = @businesses.left_outer_joins(:licenses).where('licenses.expiration_date <= ? OR licenses.expiration_date IS NULL', Date.today).distinct
    end

    @businesses = @businesses.paginate(page: params[:page], per_page: 10)
  end

  def show
    @business = Business.find(params[:id])
    @address = @business.address
  end

  def new
    @address = Address.find(params[:address_id])
    @business = Business.new
  end

  def new_business
    @business = Business.new
  end

  def create_business
    @business = Business.new(business_params)
    address = Address.find(params[:business][:address_id])

    # Check if a new unit number is provided
    if @business.new_unit_number.present?
      # Create a new unit associated with the address
      unit = address.units.create(number: @business.new_unit_number)

      if unit.persisted?
        @business.unit = unit  # Associate the new unit with the business
      else
        Rails.logger.error "Failed to create unit: #{unit.errors.full_messages.join(', ')}"
        flash[:error] = 'Failed to create the new unit. Please try again.'
        render :new_business and return
      end
    end

    if @business.save
      flash[:success] = 'Business was successfully created.'
      redirect_to businesses_path # Adjust the redirection path if needed
    else
      Rails.logger.error "Failed to save business: #{@business.errors.full_messages.join(', ')}"
      render :new_business
    end
  end

  def new_unit_business
    @unit = Unit.find(params[:unit_id])
    @business = Business.new
  end

  def create
    @address = Address.find(params[:address_id])
    @business = @address.businesses.build(business_params)
  
    if @business.save
      flash[:success] = 'Business was successfully created.'
      redirect_to @address # You may want to adjust the redirection path
    else
      render :new
    end
  end
  

  def edit
    @address = Address.find(params[:address_id])
    @business = Business.find(params[:id])
  end

  def update
    @address = Address.find(params[:address_id])
    @business = Business.find(params[:id])
    if @business.update(business_params)
      redirect_to address_business_path(@address, @business)
    else
      render 'edit'
    end
  end

  def destroy
    @address = Address.find(params[:address_id])
    @business = Business.find(params[:id])
    @business.destroy
    redirect_to address_path(@address)
  end

  private

  def business_params
    params.require(:business).permit(:name, :phone, :email, :website, :address_id, :unit_id, :contact_ids, :trading_as, :new_unit_number)
  end
end