class CitationsController < ApplicationController
  def new
    @violation = Violation.find(params[:violation_id])
    @citation = @violation.citations.new
    @code_ids = @violation.code_ids
    @address = @violation.address
    @address_citations = @address.violations.map(&:citations).flatten
    @address_photos = (
                        @address.violations.map(&:photos) +
                        @address.comments.map(&:photos) + 
                        @address_citations.map(&:photos)
                      ).flatten.sort_by(&:created_at).reverse
  end

  def create
    @violation = Violation.find(params[:violation_id])
    @citation = @violation.citations.build(citation_params)
    @citation.user = current_user
    @address = @violation.address
    @address_citations = @address.violations.map(&:citations).flatten
    @address_photos = (
                        @address.violations.map(&:photos) +
                        @address.comments.map(&:photos) + 
                        @address_citations.map(&:photos)
                      ).flatten.sort_by(&:created_at).reverse
    if @citation.save
      redirect_to violation_path(@violation), notice: "Citation created successfully"
    else
      @code_ids = @violation.code_ids
      render :new
    end
  end

  def my_citations
    @status = params[:status]
    @citations = Citation.where(user: current_user).order(created_at: :desc)

    case @status
    when "current"
      #status is unpaid or pending trial
      @citations = @citations.where(status: [:unpaid])
    when "resolved"
      #status is paid or dismissed
      @citations = @citations.where(status: [:paid, :dismissed])
    when "pending"
      #status is pending trial
      @citations = @citations.where(status: "pending trial")
    else
      @status = "all"
    end

    @citations = @citations.where(user: current_user).order(created_at: :desc)
  end

  def all_citations
    @status = params[:status]
    @citations = Citation.all.order(created_at: :desc)

    case @status
    when "current"
      #status is unpaid or pending trial
      @citations = @citations.where(status: [:unpaid])
    when "resolved"
      #status is paid or dismissed
      @citations = @citations.where(status: [:paid, :dismissed])
    when "pending"
      #status is pending trial
      @citations = @citations.where(status: "pending trial")
    else
      @status = "all"
    end

    @citations = @citations.order(created_at: :desc)
  end

  def show
    @citation = Citation.find(params[:id])
    @violation = @citation.violation
    @address = @violation.address
    @address_citations = @address.violations.map(&:citations).flatten
    @address_photos = (
                        @address.violations.map(&:photos) +
                        @address.comments.map(&:photos) + 
                        @address_citations.map(&:photos)
                      ).flatten.sort_by(&:created_at).reverse
                      
  end

  def edit
    @citation = Citation.find(params[:id])
    @violation = @citation.violation
    @address = @violation.address
    @address_citations = @address.violations.map(&:citations).flatten
    @address_photos = (
                        @address.violations.map(&:photos) +
                        @address.comments.map(&:photos) + 
                        @address_citations.map(&:photos)
                      ).flatten.sort_by(&:created_at).reverse
  end

  def update
    @citation = Citation.find(params[:id])
    @violation = @citation.violation
    @address = @violation.address
    @address_citations = @address.violations.map(&:citations).flatten
    @address_photos = (
                        @address.violations.map(&:photos) +
                        @address.comments.map(&:photos) + 
                        @address_citations.map(&:photos)
                      ).flatten.sort_by(&:created_at).reverse
    
    if @citation.update(citation_params)
      redirect_to citation_path(@citation), notice: "Citation was successfully updated."
    else
      render :edit
    end
  end

  private

  def citation_params
    params.require(:citation).permit(:fine, :deadline, :status, :trial_date, :code_id, photos: [])
  end
end
