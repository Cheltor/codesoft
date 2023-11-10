class ViolationComment < ApplicationRecord
  belongs_to :violation
  belongs_to :user
end
