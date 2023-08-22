class Address < ApplicationRecord
    has_many :comments
    has_many :users, through: :comments
    has_many :violations
    has_many :concerns, dependent: :destroy
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
