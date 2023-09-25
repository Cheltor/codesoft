class AreasController < ApplicationController
  #All of these redirects need to be updated to the new routes
  def create
    @address = Address.find(params[:address_id])
    @inspection = @address.inspections.find(params[:inspection_id])
    @area = @inspection.areas.build(area_params)

    if @area.save
      # Redirect to the conduct action of the InspectionsController
      redirect_to conduct_address_inspection_path(@address, @inspection)
    else
      # Handle errors if the area couldn't be saved
      render :new
    end
  end

  def show
    
  end

  def edit
    
  end

  def update
    @area = Area.find(params[:id])

    if @area.update(area_params)
      redirect_to @area
    else
      render :edit
    end
  end

  def new
    @address = Address.find(params[:address_id])
    @inspection = @address.inspections.find(params[:inspection_id])
    @area = @inspection.areas.build
  end

  def destroy
    @area = Area.find(params[:id])
    @area.destroy

    redirect_to conduct_address_inspection_path(@address, @inspection)
  end

  private

  def area_params
    params.require(:area).permit(:name, :notes, :inspection_id, photos: [])
  end
end