class Notification < ApplicationRecord
  belongs_to :inspection
  belongs_to :user
  
  def mark_as_read
    update(read: true)
  end
end
