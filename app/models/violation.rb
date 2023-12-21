class Violation < ApplicationRecord
  belongs_to :address
  has_many :violation_codes, dependent: :destroy
  has_many :codes, through: :violation_codes
  belongs_to :user
  validate :at_least_one_code_selected
  has_many_attached :photos
  validates :violation_type, presence: true
  has_many :citations
  belongs_to :unit, optional: true
  has_many :violation_comments, dependent: :destroy
  belongs_to :business, optional: true

  scope :created_within, -> (range) { where(created_at: range) }
  scope :warnings_created_within, -> (range) { created_within(range).where(violation_type: "Doorhanger") }
  scope :violations_created_within, -> (range) { created_within(range).where(violation_type: "Formal Notice") }



  def at_least_one_code_selected
    errors.add(:base, "Please select at least one code") if codes.none?
  end
  
  enum status: [:current, :resolved]

  after_initialize :set_default_status, if: :new_record?

  scope :recent, -> { order(created_at: :desc) }
  
  DEADLINE_OPTIONS = [
    "Immediate",
    "1 day",
    "3 days",
    "7 days",
    "14 days",
    "30 days"
  ]

  DEADLINE_VALUES = [0, 1, 3, 7, 14, 30]

  def deadline_passed?
    deadline_index = DEADLINE_OPTIONS.index(deadline)
    return false if deadline_index.nil?
    created_at + DEADLINE_VALUES[deadline_index].days + extend.days < Time.now
  end

  def deadline_date
    deadline_index = DEADLINE_OPTIONS.index(deadline)
    return false if deadline_index.nil?
    deadline_value = DEADLINE_VALUES[deadline_index]
    if deadline_value.nil?
      raise "Custom deadline value not supported"
    else
      created_at + deadline_value.days + extend.days
    end
  end

  validates :deadline, presence: true, inclusion: { in: DEADLINE_OPTIONS }
  
  
  private

  def set_default_status
    self.status ||= :current
  end
end
