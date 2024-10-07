class AreasController < ApplicationController
  layout 'choices', only: [:new, :edit]

  #All of these redirects need to be updated to the new routes
  def create
    @address = Address.find(params[:address_id])
    @inspection = @address.inspections.find(params[:inspection_id])
    @area = @inspection.areas.build(area_params)
  
    if @area.save
      if params[:create_and_new]
        redirect_to new_address_inspection_area_path(@address, @inspection)
      elsif params[:submit_and_redirect]
        redirect_to conduct_address_inspection_path(@address, @inspection)
      elsif params[:create_and_observation]
        redirect_to address_inspection_area_path(@address, @inspection, @area)
      else
        redirect_to conduct_address_inspection_path(@address, @inspection)
      end
    else
      @rooms = Room.all
      render :new
    end
  end

  def show
    @address = Address.find(params[:address_id])
    @inspection = @address.inspections.find(params[:inspection_id])
    @area = @inspection.areas.find(params[:id])
    @observation = @area.observations.build
    @prompts = @area.room.present? ? @area.room.prompts : []
  end

  def edit
    @address = Address.find(params[:address_id])
    @inspection = @address.inspections.find(params[:inspection_id])
    @area = @inspection.areas.find(params[:id])
  end

  def update
    @area = Area.find(params[:id])
    @address = @area.inspection.address
    @inspection = @area.inspection

    if @area.update(area_params)
      redirect_to conduct_address_inspection_path(@address, @inspection)
    else
      render :edit
    end
  end

  def new
    @address = Address.find(params[:address_id])
    @inspection = @address.inspections.find(params[:inspection_id])
    @area = @inspection.areas.build
    @rooms = Room.all
  
    if params[:unit_id]
      @unit = Unit.find(params[:unit_id])
      @area.unit = @unit
    end
  end
  
  

  def destroy
    @area = Area.find(params[:id])
    @area.destroy

    redirect_to conduct_address_inspection_path(@address, @inspection)
  end

  private

  def area_params
    params.require(:area).permit(:room_id, :floor, :name, :notes, :unit_id, :inspection_id, code_ids: [], photos: [])
  end
end