class InspectionComment < ApplicationRecord
  belongs_to :user
  belongs_to :inspection
  has_many_attached :photos
end
