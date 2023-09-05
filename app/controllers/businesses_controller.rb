class BusinessesController < ApplicationController
  def index
    @businesses = Business.all
  end

  def show
    @business = Business.find(params[:id])
  end

  def new
    @address = Address.find(params[:address_id]) if params[:address_id].present?
    @unit = Unit.find(params[:unit_id]) if params[:unit_id].present?
    @business = Business.new
  end

  def create
    @address = Address.find(params[:address_id]) if params[:address_id].present?
    @unit = Unit.find(params[:unit_id]) if params[:unit_id].present?
    @business = @address.businesses.build(business_params) if @address
    @business = @unit.businesses.build(business_params) if @unit

    if @business.save
      flash[:success] = 'Business was successfully created.'
      redirect_to @address || @unit
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
      redirect_to address_path(@address)
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
    params.require(:business).permit(:name, :contact, :phone, :email, :website, :address_id)
  end
end