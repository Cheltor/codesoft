class Observation < ApplicationRecord
  belongs_to :area
  has_many_attached :photos
end
