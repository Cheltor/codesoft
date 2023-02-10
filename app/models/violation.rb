class Violation < ApplicationRecord
  belongs_to :address
  has_many :violation_codes
  has_many :codes, through: :violation_codes
  belongs_to :user

  enum status: [:current, :resolved]

  after_initialize :set_default_status, if: :new_record?

  scope :recent, -> { order(created_at: :desc) }

  private

  def set_default_status
    self.status ||= :current
  end
end
