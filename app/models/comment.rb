class Comment < ApplicationRecord
  belongs_to :address
  belongs_to :user

  has_many :photos
  accepts_nested_attributes_for :photos
  
  scope :recent, -> { order(created_at: :desc) }
end
