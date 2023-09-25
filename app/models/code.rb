class Code < ApplicationRecord
    has_many :violation_codes
    has_many :violations, through: :violation_codes
    has_many :citations
    has_many :inspection_codes
    has_many :inspections, through: :inspection_codes
    has_many :area_codes
    has_many :areas, through: :area_codes, class_name: 'Area'

    validates :chapter, presence: true
    validates :section, presence: true
    validates :chapter, uniqueness: { scope: :section, message: " and Section combination exists. Double check that this isn't already in the system." }

    scope :not_associated_with_violation, ->(violation) { where.not(id: violation.code_ids) }
    validate :section_without_hyphen

    def self.ransackable_attributes(auth_object = nil)
      ["chapter", "created_at", "description", "id", "name", "section", "updated_at"]
    end
    def self.ransackable_associations(auth_object = nil)
      ["citations", "violation_codes", "violations"]
    end

    private 
  
    def section_without_hyphen
      if section.include?('-')
        errors.add(:section, "The section cannot contain a hyphen (-). Just use the second number. For example, for 50-1, just put 1.")
      end
    end
end
