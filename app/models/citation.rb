class Citation < ApplicationRecord
  belongs_to :violation
  has_and_belongs_to_many :codes
end
