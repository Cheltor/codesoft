class Area < ApplicationRecord
  belongs_to :inspection
  has_many_attached :photos
end
