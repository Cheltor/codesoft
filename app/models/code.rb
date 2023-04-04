class Code < ApplicationRecord
    has_many :violation_codes
    has_many :violations, through: :violation_codes
    has_and_belongs_to_many :citations

    validates :chapter, presence: true
    validates :section, presence: true
    validates :chapter, uniqueness: { scope: :section, message: " and Section combination exists. Double check that this isn't already in the system." }

    scope :not_associated_with_violation, ->(violation) { where.not(id: violation.code_ids) }
    validate :section_without_hyphen

    private
  
    def section_without_hyphen
      if section.include?('-')
        errors.add(:section, "The section cannot contain a hyphen (-). Just use the second number. For example, for 50-1, just put 1.")
      end
    end
end
