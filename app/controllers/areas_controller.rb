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
      render :new
    end
  end

  def show
    @address = Address.find(params[:address_id])
    @inspection = @address.inspections.find(params[:inspection_id])
    @area = @inspection.areas.find(params[:id])
    @observation = @area.observations.build
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
  
    # Use the area_type from params to perform any setup or conditional logic
    # For example, setting a transient attribute if you have one:
    @area.area_type = params[:area_type] if params[:area_type].present?
  
    # Or simply storing it in an instance variable to use in the view
    @area_type = params[:area_type]
  end
  
  

  def destroy
    @area = Area.find(params[:id])
    @area.destroy

    redirect_to conduct_address_inspection_path(@address, @inspection)
  end

  private

  def area_params
    params.require(:area).permit(:floor, :name, :notes, :inspection_id, code_ids: [], photos: [])
  end
end