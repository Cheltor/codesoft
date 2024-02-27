class BusinessesController < ApplicationController
  layout 'choices', only: [:new, :edit, :new_business]


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
    if @business.save
      flash[:success] = 'Business was successfully created.'
      redirect_to businesses_path # You may want to adjust the redirection path
    else
      render :new_business
    end
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
    params.require(:business).permit(:name, :phone, :email, :website, :address_id, :unit_id, :contact_ids, :trading_as)
  end
end