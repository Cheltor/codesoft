class Code < ApplicationRecord
    has_many :violation_codes
    has_many :violations, through: :violation_codes

    validates :chapter, presence: true
    validates :section, presence: true
    validates :chapter, uniqueness: { scope: :section, message: " and Section combination exists. Double check that this isn't already in the system." }
end
