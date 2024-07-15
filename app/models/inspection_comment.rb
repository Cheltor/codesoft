class InspectionComment < ApplicationRecord
  belongs_to :user
  belongs_to :inspection
  has_many_attached :photos
  has_paper_trail
end
