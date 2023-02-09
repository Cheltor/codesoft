class Violation < ApplicationRecord
  belongs_to :address

  enum status: [:current, :resolved]

  after_initialize :set_default_status, if: :new_record?

  private

  def set_default_status
    self.status ||= :current
  end
end
