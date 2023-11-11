class ViolationsController < ApplicationController
  before_action :set_address, except: [:sir, :show, :edit, :update]
  before_action :set_violation, only: [:resolve, :extender, :update, :edit]
  layout 'choices', only: [:new, :edit]
  before_action :require_ons_or_admin, except: [:sir]

  def new
    @violation = @address.violations.new

    @violation.code_ids = params[:code_ids].split(',') if params[:code_ids].present?
  end

  def update
    @new_violation = @address.violations.new(violation_params)
    @new_violation.user = current_user

    if @new_violation.save
      @violation.update(status: :resolved)
      redirect_to address_path(@address), notice: "Violation created successfully"
    else
      render :edit
    end
  end

  def edit
  end

  def show 
    @violation = Violation.find(params[:id])
    @address = @violation.address
    @address_citations = @address.violations.map(&:citations).flatten
    @unit = @violation.unit
    @address_photos = (
                        @address.violations.map(&:photos) +
                        @address.comments.map(&:photos) + 
                        @address_citations.map(&:photos)
                      ).flatten.sort_by(&:created_at).reverse
  end

  def sir 
    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])
      @complaints_made = Inspection.where(created_at: start_date..end_date, source: "Complaint")
      @complaint_responses = Inspection.where(created_at: start_date..end_date, source: "Complaint").where.not(status: nil)
      @warnings = Violation.where(created_at: start_date..end_date, violation_type: "Doorhanger")
      @violations = Violation.where(created_at: start_date..end_date, violation_type: "Formal Notice")
      @citations = Citation.where(created_at: start_date..end_date)
      # Single Family Inspections created in the date range
      @sf_inspections = Inspection.where(created_at: start_date..end_date, source: "Single Family License")
      # Single Family Inspections updated in the date range
      @sf_inspections_updated = Inspection.where(updated_at: start_date..end_date, source: "Single Family License")
      # Single Family Inspections approved in the date range
      @sf_inspections_approved = Inspection.where(updated_at: start_date..end_date, source: "Single Family License", status: "Satisfactory")
      # Multifamily Inspections created in the date range
      @mf_inspections = Inspection.where(created_at: start_date..end_date, source: "Multifamily License")
      # Multifamily Inspections updated in the date range
      @mf_inspections_updated = Inspection.where(updated_at: start_date..end_date, source: "Multifamily License")
      # Multifamily Inspections approved in the date range
      @mf_inspections_approved = Inspection.where(updated_at: start_date..end_date, source: "Multifamily License", status: "Satisfactory")
      # Business License Inspections created in the date range
      @bl_inspections = Inspection.where(created_at: start_date..end_date, source: "Business license")
      # Business License Inspections updated in the date range
      @bl_inspections_updated = Inspection.where(updated_at: start_date..end_date, source: "Business license")
      # Business License Inspections approved in the date range
      @bl_inspections_approved = Inspection.where(updated_at: start_date..end_date, source: "Business license", status: "Satisfactory")
      # Permit Inspections created in the date range
      @permit_inspections = Inspection.where(created_at: start_date..end_date, source: "Building/Dumpster/POD permit")
      # Permit Inspections updated in the date range
      @permit_inspections_updated = Inspection.where(updated_at: start_date..end_date, source: "Building/Dumpster/POD permit")
    else
      @complaints_made = Inspection.where("created_at >= ? AND source = ?", 2.weeks.ago, "Complaint")
      @complaint_responses = Inspection.where("created_at >= ? AND source = ?", 2.weeks.ago, "Complaint").where.not(status: nil)
      @warnings = Violation.where("created_at >= ? AND violation_type = ?", 2.weeks.ago, "Doorhanger")
      @violations = Violation.where("created_at >= ? AND violation_type = ?", 2.weeks.ago, "Formal Notice")
      @citations = Citation.where("created_at >= ?", 2.weeks.ago)
      
      @sf_inspections = Inspection.where("created_at >= ? AND source = ?", 2.weeks.ago, "Single Family License")
      @sf_inspections_updated = Inspection.where("updated_at >= ? AND source = ?", 2.weeks.ago, "Single Family License")
      @sf_inspections_approved = Inspection.where("updated_at >= ? AND source = ? AND status = ?", 2.weeks.ago, "Single Family License", "Satisfactory")
      
      @mf_inspections = Inspection.where("created_at >= ? AND source = ?", 2.weeks.ago, "Multifamily License")
      @mf_inspections_updated = Inspection.where("updated_at >= ? AND source = ?", 2.weeks.ago, "Multifamily License")
      @mf_inspections_approved = Inspection.where("updated_at >= ? AND source = ? AND status = ?", 2.weeks.ago, "Multifamily License", "Satisfactory")
      
      @bl_inspections = Inspection.where("created_at >= ? AND source = ?", 2.weeks.ago, "Business license")
      @bl_inspections_updated = Inspection.where("updated_at >= ? AND source = ?", 2.weeks.ago, "Business license")
      @bl_inspections_approved = Inspection.where("updated_at >= ? AND source = ? AND status = ?", 2.weeks.ago, "Business license", "Satisfactory")
      
      @permit_inspections = Inspection.where("created_at >= ? AND source = ?", 2.weeks.ago, "Building/Dumpster/POD permit")
      @permit_inspections_updated = Inspection.where("updated_at >= ? AND source = ?", 2.weeks.ago, "Building/Dumpster/POD permit")
    end
  end

  def create
    @violation = @address.violations.new(violation_params)
    @violation.user = current_user

    if @violation.save
      redirect_to @address, notice: "Violation reported successfully."
    else
      render :new
    end
  end

  def resolve
    if @violation.update(status: :resolved)
      redirect_to @violation, notice: "Violation resolved successfully."
    else
      redirect_to @violation, alert: "Failed to resolve violation."
    end
  end

  def extend_deadline
    @violation = Violation.find(params[:id])
  end

  def update_deadline
    days = params[:days].to_i
    @violation.extend += days
    if @violation.save
      @violation.reload
      redirect_to @violation, notice: "Extended by #{days} days"
    else
      redirect_to @violation, alert: "Failed to extend"
    end
  end

  def generate_report
    @violation = Violation.find(params[:id])
    template_path = "#{Rails.root}/lib/templates/violation_report.docx"
    template = Sablon.template(File.expand_path(template_path))
  
    today = Time.zone.now.strftime("%B %d, %Y")

    # Format the date string
    formatted_date = @violation.created_at.in_time_zone("Eastern Time (US & Canada)").strftime("%B %d, %Y")
  
    # Replace the placeholders in the document with the data
    rendered_template = template.render_to_string(
      {
        violation: {
          created_at: formatted_date,
          today: today,
          deadline_date: @violation.deadline_date.in_time_zone("Eastern Time (US & Canada)").strftime("%B %d, %Y"),
          username: @violation.user.name,
          userphone: @violation.user.phone,
          violation_codes: @violation.violation_codes
        },
        address: {
          combadd: @violation.address.combadd.titleize,
          premisezip: @violation.address.premisezip,
          ownername: @violation.address.ownername.titleize,
          owneraddress: @violation.address.owneraddress.titleize,
          ownercity: @violation.address.ownercity.titleize,
          ownerstate: @violation.address.ownerstate,
          ownerzip: @violation.address.ownerzip
        }
        # Add more data here as needed
      }
    )
  
    # Write the generated file to disk
    output_path = "#{Rails.root}/tmp/violation_report.docx"
    File.open(output_path, "wb") do |f|
      f.write(rendered_template)
    end

    # Format the address and today's date for the filename
    formatted_address = @address.combadd.gsub(/[^\w\s-]/, '').gsub(/[\s]/, '_')
    formatted_date = Time.zone.now.strftime("%Y-%m-%d")
    filename = "violation_notice_#{formatted_address}_#{formatted_date}.docx"
    
    # Send the generated file as a download with the custom filename
    send_file(output_path, filename: filename, type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document")
  end

  private

  def set_address
    if params[:address_id].present?
      @address = Address.find(params[:address_id])
      if params[:unit_id].present?
        @unit = Unit.find(params[:unit_id])
      end
    elsif params[:id].present?
      @violation = Violation.find(params[:id])
      @address = @violation.address
    end
  end  

  def violation_params
    params.require(:violation).permit(:description, :deadline, :status, :extend, :violation_type, :unit_id, photos: [], code_ids: [])
  end

  def set_violation
    @violation = Violation.find(params[:id])
    @address = @violation.address
  end

  def require_ons_or_admin
    unless current_user&.ons? || current_user&.admin?
      flash[:alert] = 'You do not have permission to perform this action.'
      redirect_to root_path
    end
  end
  
end
