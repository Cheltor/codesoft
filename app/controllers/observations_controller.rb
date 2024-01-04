class ObservationsController < ApplicationController
  def create
    @address = Address.find(params[:address_id])
    @inspection = @address.inspections.find(params[:inspection_id])
    @area = @inspection.areas.find(params[:area_id])
    @observation = @area.observations.create(observation_params)

    if @observation.save
      flash[:notice] = "Observation saved successfully. Photo attached: #{@observation.photos.attached?}"
    else
      flash[:alert] = "Failed to save observation: #{@observation.errors.full_messages.join(", ")}"
    end

    redirect_to address_inspection_area_path(@address, @inspection, @area)
  end

  def edit
    @address = Address.find(params[:address_id])
    @inspection = @address.inspections.find(params[:inspection_id])
    @area = @inspection.areas.find(params[:area_id])
    @observation = @area.observations.find(params[:id])
  end
  
  def update
    @address = Address.find(params[:address_id])
    @inspection = @address.inspections.find(params[:inspection_id])
    @area = @inspection.areas.find(params[:area_id])
    @observation = @area.observations.find(params[:id])
    
    if @observation.update(observation_params)
      redirect_to address_inspection_area_path(@address, @inspection, @area)
    else
      render 'edit'
    end
  end

  private

  def observation_params
    params.require(:observation).permit(:content, :area_id, :potentialvio, photos: [])
  end
end