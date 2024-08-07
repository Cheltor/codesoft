class LicensesController < ApplicationController
  def index
    current_year = Time.zone.now.year
    fiscal_year_start = Date.new(current_year, 7, 1)
    fiscal_year_end = Date.new(current_year + 1, 6, 30)

    @licenses = License.where("created_at >= ? AND created_at <= ?", fiscal_year_start, fiscal_year_end).order(created_at: :desc).paginate(page: params[:page], per_page: 10)
    if params[:sent].present?
      @licenses = @licenses.where(sent: params[:sent] == 'true')
    end
    if params[:paid].present?
      @licenses = @licenses.where(paid: params[:paid] == 'true')
    end
    if params[:license_type].present?
      @licenses = @licenses.where(license_type: params[:license_type])
    end
  end

  def show
    @license = License.find(params[:id])
    @inspection = Inspection.find(@license.inspection_id)
    @address = Address.find(@inspection.address_id)
  end

  def new
    @license = License.new
  end

  def create
    # Your code here
  end

  def edit
    @license = License.find(params[:id])
  end

  def update
    @license = License.find(params[:id])

    if @license.update(license_params)
      redirect_to @license, notice: 'License was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @license = License.find(params[:id])
    @license.destroy
    redirect_to licenses_url, notice: 'License was successfully destroyed.'
  end

  def email_license
    # Your code here
  end

  def download_license
    # Your code here
  end

  def generate_business
    @license = License.find(params[:id])
    @business = Business.find(@license.inspection.business_id)
    @address = @business.address

    template_path = "#{Rails.root}/lib/templates/BusinessLicenseTemplate.docx"
    template = Sablon.template(File.expand_path(template_path))

    today = Time.zone.now.in_time_zone("Eastern Time (US & Canada)").strftime("%B %d, %Y")

    # Replace the placeholders in the document with the data
    rendered_template = template.render_to_string(
      {
        business: {
          name: @business.business_name_and_trading_name,
          address: @license.inspection.unit.present? ? "#{@address.combadd}, Unit #{@license.inspection.unit}" : @address.combadd,

      },
        license: {
          conditions: @license.conditions.blank? ? "None" : @license.conditions,
          fiscal_year: @license.fiscal_year,
          today: today,
          license_number: @license.license_number,
          expiration_date: @license.expiration_date.in_time_zone("Eastern Time (US & Canada)").strftime("%B %d, %Y"),
      }
    }
    )

    # Write the generated file to disk
    output_path = "#{Rails.root}/tmp/business_license_inspection.docx"
    File.open(output_path, 'wb') do |f|
      f.write(rendered_template)
    end

    # Format the address and today's date for the filename
    formatted_address = @address.combadd.gsub(/[^\w\s-]/, '').gsub(/[\s]/, '_')
    formatted_date = Time.zone.now.strftime("%Y-%m-%d")
    filename = "Business_License_#{@business.business_name_and_trading_name}_#{formatted_date}.docx"

    # Send the file as a download with the custom filename
    send_file output_path, filename: filename, type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  end

  def generate_single_family
    @license = License.find(params[:id])
    @inspection = Inspection.find(@license.inspection_id)
    @address = Address.find(@inspection.address_id)

    template_path = "#{Rails.root}/lib/templates/SingleFamilyRentalLicenseTemplate.docx"
    template = Sablon.template(File.expand_path(template_path))

    today = Time.zone.now.in_time_zone("Eastern Time (US & Canada)").strftime("%B %d, %Y")

    # Replace the placeholders in the document with the data
    rendered_template = template.render_to_string(
      {
        address: {
          combadd: @address.combadd,
          owner: @address.ownername,
        },
        license: {
          conditions: @license.conditions.blank? ? "None" : @license.conditions,
          fiscal_year: @license.fiscal_year,
          today: today,
          license_number: @license.license_number,
          expiration_date: @license.expiration_date.in_time_zone("Eastern Time (US & Canada)").strftime("%B %d, %Y"),
      },
      inspection: {
        bedrooms: 0,
      }
    }
    )

    # Write the generated file to disk
    output_path = "#{Rails.root}/tmp/single_family_license_inspection.docx"
    File.open(output_path, 'wb') do |f|
      f.write(rendered_template)
    end

    # Format the address and today's date for the filename
    formatted_address = @address.combadd.gsub(/[^\w\s-]/, '').gsub(/[\s]/, '_')
    formatted_date = Time.zone.now.strftime("%Y-%m-%d")
    filename = "Single_Family_Rental_License_#{@address.combadd}_#{formatted_date}.docx"

    # Send the file as a download with the custom filename
    send_file output_path, filename: filename, type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  end

  def sent_today
    @license = License.find(params[:id])
    @license.update(sent: true)
    redirect_to @license, notice: 'License was updated to show it was sent.'
  end
  
  def not_sent
    @license = License.find(params[:id])
    @license.update(sent: false)
    redirect_to @license, notice: 'License was updated to show it was not sent.'
  end

  def paid
    @license = License.find(params[:id])
    @license.update(paid: true)
    redirect_to @license, notice: 'License was updated to show it was paid.'
  end
  def not_paid
    @license = License.find(params[:id])
    @license.update(paid: false)
    redirect_to @license, notice: 'License was updated to show it was not paid.'
  end
  
  private

  def license_params
    params.require(:license).permit(:sent, :revoked, :license_type, :fiscal_year, :license_number, :expiration_date, :inspection_id, :business_id, :date_issued, :conditions)
  end
end
