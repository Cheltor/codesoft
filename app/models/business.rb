class Business < ApplicationRecord
  belongs_to :address
  belongs_to :unit, optional: true
  has_many :business_contacts
  has_many :contacts, through: :business_contacts
  has_many :inspections
  has_many :violations
  has_many :licenses

  has_paper_trail

  validates :name, presence: true
  validates :address, presence: true

  validates :name, uniqueness: { scope: [:address_id, :email, :phone] }
  
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

  def licensed
    licenses.where('expiration_date > ?', Date.today).exists?
  end

  private

  def normalize_website
    if website.present?
      self.website = "http://#{website}" unless website[/\Ahttp:\/\//] || website[/\Ahttps:\/\//]
    end
  end
end
