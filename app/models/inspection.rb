class Inspection < ApplicationRecord
  belongs_to :unit, optional: true
  belongs_to :address
  has_many :violations, dependent: :destroy
  belongs_to :user, optional: true
  has_many_attached :attachments
  belongs_to :assignee, class_name: "User", foreign_key: "assignee_id", optional: true
  belongs_to :inspector, class_name: "User", optional: true

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, format: { with: /\A\d{10}\z/ }
  
end
