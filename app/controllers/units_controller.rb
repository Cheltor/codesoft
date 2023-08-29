class UnitsController < ApplicationController
  def index
    @address = Address.find(params[:address_id])
    @units = @address.units
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
      render :new
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
