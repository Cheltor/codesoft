class ContactComment < ApplicationRecord
  belongs_to :user
  belongs_to :contact
  has_paper_trail
end
