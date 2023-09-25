class Inspection < ApplicationRecord
  belongs_to :unit, optional: true
  belongs_to :address
  has_many :violations, dependent: :destroy
  belongs_to :user, optional: true
  has_many_attached :attachments
  has_many_attached :photos
  has_many_attached :intphotos
  has_many_attached :extphotos
  belongs_to :assignee, class_name: "User", foreign_key: "assignee_id", optional: true
  belongs_to :inspector, class_name: "User", optional: true
  has_many :inspection_codes
  has_many :codes, through: :inspection_codes
  belongs_to :contact, optional: true
  has_many :areas, dependent: :destroy
end
