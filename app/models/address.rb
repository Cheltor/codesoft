class Address < ApplicationRecord
    has_many :comments
    has_many :users, through: :comments
    has_many :violations
    has_many :concerns, dependent: :destroy
    has_many :units, dependent: :destroy
    has_many :inspections, dependent: :destroy
    has_many :businesses, dependent: :destroy
    has_many :address_contacts
    has_many :contacts, through: :address_contacts
    before_create :generate_combadd
    before_save :upcase_streetname
    before_save :upcase_streettype
    before_save :upcase_ownername
    before_save :upcase_owneraddress
    before_save :upcase_ownercity
    before_save :upcase_ownerstate
    after_initialize :set_default_vacancy_status, :if => :new_record?

    geocoded_by :full_street_address
    after_validation :geocode, if: ->(obj){ obj.full_street_address.present? and obj.streetnumb_changed? and obj.streetname_changed? and obj.streettype_changed? }

    default_scope { where.not(streetnumb: nil) }

    def full_street_address
        "#{streetnumb} #{streetname} #{streettype}, Maryland, 20737"
    end

    def self.ransackable_attributes(auth_object = nil)
        ["property_name", "absent", "combadd", "created_at", "id", "landusecode", "outstanding", "owneraddress", "ownercity", "ownername", "owneroccupiedin", "ownerstate", "ownerzip", "pid", "premisezip", "streetname", "streetnumb", "streettype", "updated_at", "vacant", "zoning", "aka"]
    end
    def self.ransackable_associations(auth_object = nil)
        ["comments", "users", "violations"]
    end

    def property_name_with_combadd
        if property_name.present?
            "#{property_name.titleize} - #{combadd}#{' (vacant unregistered)' if vacancy_status == 'vacant'}#{' (vacant registered)' if vacancy_status == 'registered'}"
        else
            "#{combadd}#{' (vacant unregistered)' if vacancy_status == 'vacant'}#{' (vacant registered)' if vacancy_status == 'registered'}"
        end
    end

    private

    def generate_combadd
        self.combadd = "#{self.streetnumb} #{self.streetname} #{self.streettype} #{self.premisezip}"
    end
    def upcase_streetname
        self.streetname = streetname.upcase if streetname.present?
    end
    def upcase_streettype 
        self.streettype = streettype.upcase if streettype.present?
    end
    def upcase_ownername
        self.ownername = ownername.upcase if ownername.present?
    end
    def upcase_owneraddress
        self.owneraddress = owneraddress.upcase if owneraddress.present?
    end
    def upcase_ownercity
        self.ownercity = ownercity.upcase if ownercity.present?
    end
    def upcase_ownerstate
        self.ownerstate = ownerstate.upcase if ownerstate.present?
    end
    def set_default_vacancy_status
        self.vacancy_status ||= 'occupied'
    end
end
