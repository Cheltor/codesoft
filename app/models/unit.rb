class Unit < ApplicationRecord
  belongs_to :address
  has_many :violations
  has_many :comments
  has_many :citations
end
