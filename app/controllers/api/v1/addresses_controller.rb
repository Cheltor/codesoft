class Api::V1::AddressesController < ActionController::Base
  def index
    @addresses = Address.all
    render json: @addresses
  end

  def show
    @address = Address.find(params[:id])
  
    # Fetch citations for the address's violations, ordered by deadline
    @address_citations = @address.violations.joins(:citations).select('citations.*').order(deadline: :desc)
  
    # Fetch photos related to violations, comments, and citations
    @address_photos = (
      @address.violations.flat_map(&:photos) +  # Assuming Violation has photos attached via Active Storage
      @address.comments.flat_map(&:photos) +    # Assuming Comment has photos attached via Active Storage
      @address_citations.flat_map(&:photos)     # Assuming Citation has photos attached
    ).sort_by(&:created_at).reverse
  
    # Count unpaid or pending trial citations
    @address_citations_count = @address.violations.map(&:citations).flatten.select { |citation| citation.status.in?([:unpaid, 'pending trial']) }.count > 0
  
    not_updated_today = !@address.updated_at.today?
  
    # Check if the address is a priority
    @is_priority_address = (@address_violations || @address_citations_count || @address_inspections) && not_updated_today
  
    # Render JSON response with user info in comments
    render json: {
      address: @address.as_json(only: [:id, :name, :streetnumb, :streetname, :property_name, :updated_at, :vacancy_status, :latitude, :longitude, :combadd]),
      photos: @address_photos.map { |photo| url_for(photo) }, # Generates URLs for Active Storage photos
      citations_count: @address_citations_count,
      is_priority_address: @is_priority_address,
    }
  end
  
  def photos
    @address = Address.find(params[:id])
    @address_photos = (
      @address.violations.flat_map(&:photos) + 
      @address.comments.flat_map(&:photos) + 
      @address.inspections.flat_map(&:photos)
    ).sort_by(&:created_at).reverse
  
    render json: @address_photos.map { |photo| url_for(photo) }
  end
  
  def violations
    @address = Address.find(params[:id])
    @violations = @address.violations
  
    render json: @violations
  end

  def inspections
    @address = Address.find(params[:id])
    @inspections = @address.inspections.where.not(source: "Complaint")
  
    render json: @inspections
  end

  def complaints
    Rails.logger.debug "Fetching address with ID: #{params[:id]}"
    @address = Address.find(params[:id])
    Rails.logger.debug "Address found: #{@address.inspect}"
    
    @complaints = @address.inspections.where(source: "Complaint")
    Rails.logger.debug "Complaints found: #{@complaints.inspect}"
  
    # Control the structure of the JSON response to avoid deep recursion
    render json: @complaints.as_json(only: [:id, :status, :description, :created_at, :updated_at], include: {
      inspector: { only: [:id, :name, :email] },
      unit: { only: [:id, :number] }
    })
  end
  

  def comments
    @address = Address.find(params[:id])
    violation_comments = @address.violations.flat_map(&:violation_comments)
    citation_comments = @address.violations.flat_map { |violation| violation.citations.flat_map(&:citation_comments) }
    address_comments = @address.comments
    inspection_comments = @address.inspections.flat_map(&:inspection_comments)
  
    combined_comments = (violation_comments + citation_comments + address_comments + inspection_comments).sort_by(&:created_at).reverse
  
    render json: combined_comments.map do |comment|
      comment.as_json(only: [:id, :content, :created_at, :updated_at, :address_id, :unit_id]).merge(
        user: comment.user.as_json(only: [:id, :email, :name])
      )
    end
  end



  
end
