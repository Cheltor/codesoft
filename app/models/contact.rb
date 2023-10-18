class Contact < ApplicationRecord
  has_many :inspections
  has_many :address_contacts
  has_many :addresses, through: :address_contacts
  has_many :contact_comments, dependent: :destroy

  scope :hidden, -> { where(hidden: true) }
  scope :visible, -> { where(hidden: false) }

  def self.ransackable_attributes(auth_object = nil)
    ["name", "email", "phone", "notes", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["address_contacts", "addresses", "inspections"]
  end

  def full_name_and_email
    "#{name} - #{email}"
  end
end
