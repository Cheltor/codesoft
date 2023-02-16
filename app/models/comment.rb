class Comment < ApplicationRecord
  belongs_to :address
  belongs_to :user

  has_many_attached :photos

  
  scope :recent, -> { order(created_at: :desc) }

  validates :content, presence: true
end
