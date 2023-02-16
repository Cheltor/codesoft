class Comment < ApplicationRecord
  belongs_to :address
  belongs_to :user
  
  scope :recent, -> { order(created_at: :desc) }

  validates :content, presence: true
end
