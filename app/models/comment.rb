class Comment < ApplicationRecord
  belongs_to :address
  belongs_to :user

  mount_uploader :photo, PhotoUploader

  scope :recent, -> { order(created_at: :desc) }
end
