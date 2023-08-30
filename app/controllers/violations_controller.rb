class ViolationsController < ApplicationController
  before_action :set_address, except: [:sir, :show, :edit, :update]
  before_action :set_violation, only: [:resolve, :extender, :update, :edit]
  layout 'new_violation', only: [:new, :edit]
  before_action :require_ons_or_admin, except: [:sir]

  def new
    @violation = @address.violations.new
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
      @violations = Violation.where(created_at: start_date..end_date)
    else
      @violations = Violation.where("created_at >= ?", 2.weeks.ago)
    end
  end

  def create
    @violation = @address.violations.new(violation_params)
    @violation.user = current_user

    if @violation.save
      redirect_to @violation, notice: "Violation reported successfully."
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

  def extender
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
