class InspectionComment < ApplicationRecord
  belongs_to :user
  belongs_to :inspection
end
