class ViolationComment < ApplicationRecord
  belongs_to :violation
  belongs_to :user
  has_many_attached :photos
end
