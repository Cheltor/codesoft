class BusinessesController < ApplicationController
  layout 'choices', only: [:new, :edit]


  def index
    @business_q = Business.ransack(params[:q])
    @businesses = @business_q.result(distinct: true).order(created_at: :desc)
  end

  def show
    @business = Business.find(params[:id])
    @address = @business.address
  end

  def new
    @address = Address.find(params[:address_id])
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
    params.require(:business).permit(:name, :phone, :email, :website, :address_id, :unit_id, :contact_ids)
  end
end