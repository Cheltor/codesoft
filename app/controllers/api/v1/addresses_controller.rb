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
  
    # Collect all timeline items (violations, comments, citations, inspections)
    @timeline_items = (
      @address.violations + 
      @address.comments + 
      @address_citations + 
      @address.inspections
    ).sort_by(&:created_at).reverse
  
    # Check if the address has any current violations
    @address_violations = @address.violations.where(status: :current)
                                  .where('deadline <= ?', Date.tomorrow)
                                  .reject { |violation| violation.citations.where(status: [:unpaid, 'pending trial']).any? { |citation| citation.deadline >= Date.tomorrow } }
                                  .any?
  
    @address_inspections = @address.inspections.where(status: nil).where.not(source: "Complaint").any?
  
    # Count unpaid or pending trial citations
    @address_citations_count = @address.violations.map(&:citations).flatten.select { |citation| citation.status.in?([:unpaid, 'pending trial']) }.count > 0
  
    not_updated_today = !@address.updated_at.today?
  
    # Check if the address is a priority
    @is_priority_address = (@address_violations || @address_citations_count || @address_inspections) && not_updated_today
  
    # Fetch complaints (inspections with source 'Complaint')
    @complaints = @address.inspections.where(source: "Complaint")
  
    # Fetch all related comments (violation, citation, inspection, and address comments) with user info
    violation_comments = @address.violations.flat_map(&:violation_comments)
    citation_comments = @address.violations.flat_map { |violation| violation.citations.flat_map(&:citation_comments) }
    address_comments = @address.comments.includes(:user) # Include user to avoid N+1 query issue
    inspection_comments = @address.inspections.flat_map(&:inspection_comments)
  
    combined_comments = (violation_comments + citation_comments + address_comments + inspection_comments).sort_by(&:created_at).reverse
  
    # Combine all items for timeline
    combined_timeline_items = (
      @address.violations.to_a + 
      combined_comments.to_a + 
      @address_citations + 
      @address.inspections.to_a
    ).sort_by(&:created_at).reverse
  
    # Paginate timeline items (optional)
    page = params[:page] || 1
    per_page = 10
    paginated_items = WillPaginate::Collection.create(page, per_page, combined_timeline_items.size) do |pager|
      start_index = pager.offset
      pager.replace(combined_timeline_items[start_index, per_page])
    end
  
    # Render JSON response with user info in comments
    render json: {
      address: @address.as_json(only: [:id, :name, :streetnumb, :streetname, :property_name, :updated_at, :vacancy_status, :latitude, :longitude, :combadd]),
      citations: @address_citations.map { |citation| citation.as_json(only: [:id, :status, :deadline, :fine]) },
      photos: @address_photos.map { |photo| url_for(photo) }, # Generates URLs for Active Storage photos
      timeline: paginated_items.map { |item| item.as_json(only: [:id, :created_at]) }, # Modify based on the actual timeline fields
      violations: @address_violations,
      citations_count: @address_citations_count,
      inspections: @address_inspections,
      is_priority_address: @is_priority_address,
      complaints: @complaints.map { |complaint| complaint.as_json(only: [:id, :description, :source]) },
      comments: combined_comments.map do |comment|
        comment.as_json(only: [:id, :content, :created_at, :updated_at, :address_id, :unit_id]).merge(
          user: comment.user.as_json(only: [:id, :email, :name]) # Include user details for each comment
        )
      end
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
  
  
  
end
