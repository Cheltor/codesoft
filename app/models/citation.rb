class Citation < ApplicationRecord
  belongs_to :violation
  belongs_to :user
  belongs_to :code
  has_many_attached :photos
  belongs_to :unit, optional: true
  has_many :citation_comments, dependent: :destroy

  scope :created_within, -> (range) { where(created_at: range) }

  has_paper_trail

  validates :fine, presence: true
  validates :deadline, presence: true
  validates :code_id, presence: true
  validates :citationid, uniqueness: true


  def deadline_passed?
    deadline < Date.today
  end

  enum status: { unpaid: 0, paid: 1, "pending trial" => 2, dismissed: 3 }

  before_create :set_default_status

  private

  def set_default_status
    self.status ||= :unpaid
  end
end
