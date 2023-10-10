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
    def toggle_outstanding_violation
        self.update_attribute(:outstanding_violation, !self.outstanding_violation)
    end      
    def self.ransackable_attributes(auth_object = nil)
        ["absent", "combadd", "created_at", "id", "landusecode", "outstanding", "owneraddress", "ownercity", "ownername", "owneroccupiedin", "ownerstate", "ownerzip", "pid", "premisezip", "streetname", "streetnumb", "streettype", "updated_at", "vacant", "zoning"]
    end
    def self.ransackable_associations(auth_object = nil)
        ["comments", "users", "violations"]
    end

    before_save :attribute_changed_today?

    def attribute_changed_today?(attribute)
        return false unless attribute_changed?(attribute)

        attribute_changed_at = send("#{attribute}_changed_at") # Assuming you have timestamps for attribute changes
        today = Date.today.beginning_of_day

        attribute_changed_at >= today
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
end
