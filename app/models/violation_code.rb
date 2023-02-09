class ViolationCode < ApplicationRecord
  belongs_to :violation
  belongs_to :code
end
