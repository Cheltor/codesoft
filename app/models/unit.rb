class Unit < ApplicationRecord
  after_initialize :set_default_vacancy_status, if: :new_record?
  
  belongs_to :address
  has_many :violations
  has_many :comments
  has_many :citations
  has_many :inspections
  has_many :businesses
  has_many :unit_contacts
  has_many :contacts, through: :unit_contacts

  has_paper_trail

  # make sure that the unit number is unique for the address
  validates :number, uniqueness: { scope: :address_id }

  def to_s
    if vacancy_status == "vacant"
      "#{number} (vacant)"
    else
      number
    end
  end

  private

  def set_default_vacancy_status
    self.vacancy_status ||= "occupied"
  end
end
