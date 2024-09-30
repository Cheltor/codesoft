class Permit < ApplicationRecord
  belongs_to :address
  belongs_to :inspection

  # When creating a new permit, set the expiration date to the next June 30th
  before_create do
    self.expiration_date = Date.new(Date.today.year, 6, 30)
    self.fiscal_year = Date.today.year
  end

  # When creating a permit, set the fiscal year. Fiscal years start on July 1st and end on June 30th.
  before_create do
    if Date.today.month > 6
      self.fiscal_year = Date.today.year + 1
    else
      self.fiscal_year = Date.today.year
    end
  end

  # When creating a permit, set the 'sent' attribute to false
  before_create do
    self.sent = false
  end

  # When creating a permit, set the 'revoked' attribute to false
  before_create do
    self.revoked = false
  end

  # When creating a permit, set the permit number
  before_create do
    self.permitnumber = SecureRandom.hex(5)
  end

  # Whenever a permit is updated, update the inspection's 'paid' attribute
  after_update do
    self.inspection.update_attribute(:paid, self.paid)
  end

end
