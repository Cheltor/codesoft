class Business < ApplicationRecord
  belongs_to :address
  belongs_to :unit, optional: true
  has_many :business_contacts
  has_many :contacts, through: :business_contacts
  has_many :inspections
  has_many :violations

  validates :name, presence: true
  validates :address, presence: true
  
  def business_name_and_trading_name
    if trading_as.present?
      "#{name} (#{trading_as})"
    else
      name
    end
  end

  before_validation :normalize_website

  def self.ransackable_attributes(auth_object = nil)
    ["name", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["address", "unit"]
  end

  def to_s
    name
  end

  private

  def normalize_website
    self.website = "http://#{website}" unless website[/\Ahttp:\/\//] || website[/\Ahttps:\/\//]
  end
end
