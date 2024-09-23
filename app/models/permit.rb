class Permit < ApplicationRecord
  belongs_to :address
  belongs_to :inspection
end
