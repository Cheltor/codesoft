class Comment < ApplicationRecord
  belongs_to :address
  belongs_to :user
  has_many_attached :photos
  belongs_to :unit, optional: true
  
  scope :recent, -> { order(created_at: :desc) }

  validates :content, presence: true
end
