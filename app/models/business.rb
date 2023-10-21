class Business < ApplicationRecord
  belongs_to :address
  belongs_to :unit, optional: true
  has_many :business_contacts
  has_many :contacts, through: :business_contacts

  def self.ransackable_attributes(auth_object = nil)
    ["name", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["address", "unit"]
  end

  def to_s
    name
  end
end
