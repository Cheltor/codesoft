class Unit < ApplicationRecord
  belongs_to :address
  has_many :violations
  has_many :comments
  has_many :citations
  has_many :inspections
  has_many :businesses

  # make sure that the unit number is unique for the address
  validates :number, uniqueness: { scope: :address_id }

  def to_s
    number
  end
end
