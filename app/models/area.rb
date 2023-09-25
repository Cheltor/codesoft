class Area < ApplicationRecord
  belongs_to :inspection
  has_many_attached :photos
  has_many :area_codes
  has_many :codes, through: :area_codes, class_name: 'Code'
end
