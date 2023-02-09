class Code < ApplicationRecord
    has_many :violation_codes
    has_many :violations, through: :violation_codes
end
