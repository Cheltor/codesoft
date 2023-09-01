class Inspection < ApplicationRecord
  belongs_to :unit, optional: true
  belongs_to :address
  has_many :violations, dependent: :destroy
  belongs_to :user, optional: true
  has_many_attached :attachments

  STATUS_OPTIONS = ["scheduled", "not scheduled"].freeze
  RESULT_OPTIONS = ["passed", "failed"].freeze
  
end
