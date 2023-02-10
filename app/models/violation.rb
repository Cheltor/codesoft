class Violation < ApplicationRecord
  belongs_to :address
  has_many :violation_codes
  has_many :codes, through: :violation_codes
  belongs_to :user

  enum status: [:current, :resolved]

  after_initialize :set_default_status, if: :new_record?

  scope :recent, -> { order(created_at: :desc) }
  
  DEADLINE_OPTIONS = [
    "Immediate",
    "1 day",
    "3 days",
    "7 days",
    "30 days"
  ]

  validates :deadline, presence: true, inclusion: { in: DEADLINE_OPTIONS }
  
  private

  def set_default_status
    self.status ||= :current
  end
end
