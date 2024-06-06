class ViolationsController < ApplicationController
  before_action :set_address, except: [:sir, :show, :edit, :update]
  before_action :set_violation, only: [:resolve, :extender, :update, :edit]
  layout 'choices', only: [:new, :edit, :new_business_violation]
  before_action :require_ons_or_admin, except: [:sir, :violist]

  def new
    @violation = @address.violations.new

    @violation.code_ids = params[:code_ids].split(',') if params[:code_ids].present?

    # If the violation is for a unit
    @unit = Unit.find(params[:unit_id]) if params[:unit_id].present?
  end

  def new_business_violation
    @business = Business.find(params[:business_id])
    @address = @business.address
    @violation = @business.violations.new
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

  def violist
    @status = params[:status]
    @user = params[:user]
    @violations = Violation.all
  
    case @status
    when "current"
      @violations = @violations.where(status: :current)
    when "resolved"
      @violations = @violations.where(status: :resolved)
    end
  
    case @user
    when "current_user"
      @violations = @violations.where(user: current_user)
    when "current_user_current"
      @violations = @violations.where(user: current_user, status: :current)
    when "current_user_resolved"
      @violations = @violations.where(user: current_user, status: :resolved)
    end
  
    @violations = @violations.order(created_at: :desc)
  
    @violations = @violations.paginate(page: params[:page], per_page: 15)
  end

  # For the MPIA request
  def export_csv
    @violations = Violation.where('created_at >= ?', 6.months.ago)

    respond_to do |format|
      format.csv { send_data generate_csv(@violations), filename: "violations-#{Date.today}.csv" }
    end
  end

  def export_property_csv
    # Ensure @address is set correctly
    puts "@address: #{@address.inspect}"

    # Get all violations for the address
    @violations = @address.violations

    # Debug output to check if violations are fetched correctly
    puts "@violations: #{@violations.inspect}"

    respond_to do |format|
      format.csv { send_data generate_property_csv(@violations), filename: "#{@address.property_name_with_combadd} violations-#{Date.today}.csv" }
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
      start_date = Date.parse(params[:start_date]).beginning_of_day
      end_date = Date.parse(params[:end_date]).end_of_day
      range = start_date..end_date
    else
      # Default to the last 2 weeks
      range = 2.weeks.ago.beginning_of_day..Time.zone.now.end_of_day
    end
  
    @complaints_made = Inspection.complaints_created_within(range)
    @complaint_responses = Inspection.complaint_responses_created_within(range)
    @warnings = Violation.warnings_created_within(range)
    @violations = Violation.violations_created_within(range)
    @citations = Citation.created_within(range)
    @sf_inspections = Inspection.sf_inspections_created_within(range)
    @sf_inspections_updated = Inspection.sf_inspections_updated_within(range)
    @sf_inspections_approved = Inspection.sf_inspections_approved_within(range)
    @mf_inspections = Inspection.mf_inspections_created_within(range)
    @mf_inspections_updated = Inspection.mf_inspections_updated_within(range)
    @mf_inspections_approved = Inspection.mf_inspections_approved_within(range)
    @bl_inspections = Inspection.bl_inspections_created_within(range)
    @bl_inspections_updated = Inspection.bl_inspections_updated_within(range)
  end

  def create
    @violation = @address.violations.new(violation_params)
    @violation.user = current_user

    if @violation.save && @violation.unit.present?
      redirect_to address_unit_path(@violation.address, @violation.unit), notice: "Violation reported successfully."
    elsif @violation.save
      redirect_to @address, notice: "Violation reported successfully."
    else
      render :new
    end
  end

  def resolve
    if @violation.update(status: :resolved)
      redirect_to @violation.address, notice: "Violation resolved successfully."
    else
      redirect_to @violation.address, alert: "Failed to resolve violation."
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
    params.require(:violation).permit(:business_id, :description, :deadline, :status, :extend, :violation_type, :unit_id, photos: [], code_ids: [])
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

  def generate_csv(violations)
    CSV.generate(headers: true) do |csv|
      csv << ["Address", "Created At", "Codes"]

      violations.each do |violation|
        codes = violation.codes.pluck(:name).join(", ")
        csv << [violation.address.property_name_with_combadd, violation.created_at, codes]
      end
    end
  end

  def generate_property_csv(violations)
    CSV.generate(headers: true) do |csv|
      csv << ["Property/unit", "Created At", "Codes"]

      violations.each do |violation|
        codes = violation.codes.pluck(:name).join(", ")
        csv << [
          violation.unit.present? ? violation.unit : violation.address.property_name_with_combadd, 
          violation.created_at, 
          codes
        ]
      end
    end
  end
  
end
