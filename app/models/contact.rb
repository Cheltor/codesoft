class Contact < ApplicationRecord
  has_many :inspections
  has_many :address_contacts
  has_many :addresses, through: :address_contacts

  def full_name_and_email
    "#{name} - #{email}"
  end
end
