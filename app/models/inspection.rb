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


  private

  def no_inspection_within_one_hour
    if scheduled_datetime.present?
      # Check if there are any other inspections scheduled within 1 hour
      if Inspection.where(inspector_id: inspector_id, status: nil)
                  .where('scheduled_datetime >= ? AND scheduled_datetime <= ?', scheduled_datetime - 1.hour, scheduled_datetime + 1.hour)
                  .where.not(id: id) # Exclude the current inspection if it's being updated
                  .exists?
        errors.add(:scheduled_datetime, "Another inspection is scheduled within 1 hour of this time.")
      end
    end
  end

  def scheduled_datetime_cannot_be_in_the_past
    if scheduled_datetime.present? && scheduled_datetime < DateTime.now
      errors.add(:scheduled_datetime, "can't be in the past")
    end
  end
end
