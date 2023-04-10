class Citation < ApplicationRecord
  belongs_to :violation
  belongs_to :user
  has_and_belongs_to_many :codes

  validates :fine, presence: true
  validates :deadline, presence: true

  def deadline_passed?
    deadline < Date.today
  end
end
