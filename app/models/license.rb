class License < ApplicationRecord
  belongs_to :inspection
  belongs_to :business, optional: true

  before_create :set_fiscal_year_and_expiration_date
  after_create :set_license_number

  enum license_type: {
    business: 0,
    single_family: 1,
    multifamily: 2,
    micromobility: 3,
    vacant_property: 4
  }

  private

  def set_fiscal_year_and_expiration_date
    today = Time.zone.now
    # Determine the fiscal year
    fiscal_year_value = today.month >= 7 ? today.year + 1 : today.year
    self.fiscal_year = "FY#{fiscal_year_value}"

    # Expiration date is the last day of the fiscal year
    self.expiration_date = Date.new(fiscal_year_value, 6, 30)
  end

  def set_license_number
    self.license_number = "#{fiscal_year}-#{license_type.to_s.upcase}-#{id.to_s.rjust(4, '0')}"
    self.save
  end
end