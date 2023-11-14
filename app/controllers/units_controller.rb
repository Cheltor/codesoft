class UnitsController < ApplicationController
  def index
    @address = Address.find(params[:address_id])
    @units = @address.units
  end

  def show
    @address = Address.find(params[:address_id])
    @unit = @address.units.find(params[:id])
    @violations = @unit.violations
    @address_citations = @unit.citations
    @inspections = @unit.inspections.where.not(source: "Complaint")
    @complaints = @inspections.where(source: "Complaint")
  
    violation_comments = @violations.flat_map(&:violation_comments)
    citation_comments = @violations.flat_map { |violation| violation.citations.flat_map(&:citation_comments) }
    @comments = []
    unit_comments = @unit.comments
  
    @comments = (violation_comments + citation_comments + unit_comments).sort_by(&:created_at).reverse
  
    @unit_photos = (@violations.map(&:photos) + @comments.map(&:photos) + @address_citations.map(&:photos)).flatten.sort_by(&:created_at).reverse
    timeline_items = (@violations + @comments + @address_citations + @inspections).sort_by(&:created_at).reverse
  
    # Paginate timeline_items
    page = params[:page] || 1
    per_page = 10 # or any number you prefer
    total_items = timeline_items.length
    @timeline_items = WillPaginate::Collection.create(page, per_page, total_items) do |pager|
      pager.replace timeline_items[pager.offset, pager.per_page].to_a
    end
  end
  
  def all_unit_comments
    @address = Address.find(params[:address_id])
    @unit = @address.units.find(params[:id])
    @comments = @unit.comments
    @violations = @unit.violations
    @address_citations = @unit.citations
    @inspections = @unit.inspections.where.not(source: "Complaint")
    @complaints = @inspections.where(source: "Complaint")

    violation_comments = @violations.flat_map(&:violation_comments)
    citation_comments = @violations.flat_map { |violation| violation.citations.flat_map(&:citation_comments) }
    @comments = []
    unit_comments = @unit.comments

    @comments = (violation_comments + citation_comments + unit_comments).sort_by(&:created_at).reverse

    @unit_photos = (@violations.map(&:photos) + @comments.map(&:photos) + @address_citations.map(&:photos)).flatten.sort_by(&:created_at).reverse

    
  end

  def all_unit_violations
    @address = Address.find(params[:address_id])
    @unit = @address.units.find(params[:id])
    @violations = @unit.violations
  end

  def all_unit_citations
    @address = Address.find(params[:address_id])
    @unit = @address.units.find(params[:id])
    @citations = @unit.citations
  end

  def all_unit_inspections
    @address = Address.find(params[:address_id])
    @unit = @address.units.find(params[:id])
    @inspections = @unit.inspections.where.not(source: "Complaint")
  end

  def all_unit_complaints
    @address = Address.find(params[:address_id])
    @unit = @address.units.find(params[:id])
    @inspections = @unit.inspections.where(source: "Complaint")
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
