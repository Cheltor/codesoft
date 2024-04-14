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
  belongs_to :business, optional: true
  has_many :inspection_comments, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_one :license, dependent: :destroy

  scope :created_within, -> (range) { where(created_at: range) }
  scope :updated_within, -> (range) { where(updated_at: range) }
  scope :complaints_created_within, -> (range) { created_within(range).where(source: "Complaint") }
  scope :complaint_responses_created_within, -> (range) { complaints_created_within(range).where.not(status: nil) }
  scope :sf_inspections_created_within, -> (range) { created_within(range).where(source: "Single Family License", status: ["Satisfactory", "Unsatisfactory"]) }
  scope :sf_inspections_updated_within, -> (range) { updated_within(range).where(source: "Single Family License") }
  scope :sf_inspections_approved_within, -> (range) { sf_inspections_updated_within(range).where(status: "Satisfactory") }
  scope :mf_inspections_created_within, -> (range) { created_within(range).where(source: "Multifamily License") }
  scope :mf_inspections_updated_within, -> (range) { updated_within(range).where(source: "Multifamily License") }
  scope :mf_inspections_approved_within, -> (range) { mf_inspections_updated_within(range).where(status: "Satisfactory") }
  scope :bl_inspections_created_within, -> (range) { created_within(range).where(source: "Business license") }
  scope :bl_inspections_updated_within, -> (range) { updated_within(range).where(source: "Business license") }

  attr_accessor :current_user

  after_create :create_notification_if_complaint
  after_update :create_notification_if_reassigned

  private

  def create_notification_if_complaint
    Rails.logger.info "Checking for complaint inspection..."
    return unless source == 'Complaint' && inspector.id != current_user.id
    Rails.logger.info "Inspection is a complaint."
    notification = Notification.create(
      inspection: self,
      user: inspector,
      title: "New Complaint Inspection for #{address.property_name_with_combadd}",
      body: "You have been assigned a new complaint inspection for #{address.property_name_with_combadd}."
    )
    NotificationMailer.notify_inspector(notification).deliver_later if notification.persisted?
    Rails.logger.info "Notification created."
  rescue => e
    Rails.logger.error "Error in create_notification_if_complaint: #{e.message}"
  end

  def create_notification_if_reassigned
    Rails.logger.info "Checking for inspection reassignment..."
    if saved_change_to_inspector_id? && inspector != current_user
      Rails.logger.info "Inspector has been reassigned."
      notification = Notification.create(
        inspection: self,
        user: inspector,
        title: "Inspection Assignment",
        body: "You have been assigned to an inspection at #{address.property_name_with_combadd}."
      )
      if notification.persisted?
        NotificationMailer.notify_inspector(notification).deliver_later
        Rails.logger.info "Notification successfully created"
      else
        Rails.logger.error "Failed to create notification: #{notification.errors.full_messages}"
      end
    else
      Rails.logger.info "Inspector has not been reassigned."
    end
  rescue => e
    Rails.logger.error "Error in create_notification_if_reassigned: #{e.message}"  
  end

  def no_inspection_within_one_hour
    if scheduled_datetime.present?
      # Check if there are any other inspections scheduled within 1 hour
      if Inspection.where(inspector_id: inspector_id, status: nil)
                  .where('scheduled_datetime >= ? AND scheduled_datetime <= ?', scheduled_datetime - 1.hour, scheduled_datetime + 1.hour)
                  .where.not(id: id) # Exclude the current inspection if it's being updated
                  .exists?
        errors.add(:scheduled_datetime, "Another inspection is scheduled within 1 hour of this time.")
        throw :abort # Prevent saving if there is an error
      end
    end
  end

  def scheduled_datetime_cannot_be_in_the_past
    if scheduled_datetime.present? && scheduled_datetime < DateTime.now
      errors.add(:scheduled_datetime, "can't be in the past")
    end
  end

  def no_inspections_within_30_minutes
    return unless scheduled_datetime

    # Define the time range
    time_range = (scheduled_datetime - 30.minutes)..(scheduled_datetime + 30.minutes)

    # Check for any inspections within this range
    if Inspection.where.not(id: id).where(scheduled_datetime: time_range).exists?
      errors.add(:scheduled_datetime, 'is too close to another inspection')
    end
  end
end
