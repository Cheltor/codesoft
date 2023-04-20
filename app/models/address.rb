class Address < ApplicationRecord
    has_many :comments
    has_many :users, through: :comments
    has_many :violations
    def toggle_outstanding_violation
        self.update_attribute(:outstanding_violation, !self.outstanding_violation)
    end      
    def self.ransackable_attributes(auth_object = nil)
        ["absent", "combadd", "created_at", "id", "landusecode", "outstanding", "owneraddress", "ownercity", "ownername", "owneroccupiedin", "ownerstate", "ownerzip", "pid", "premisezip", "streetname", "streetnumb", "streettype", "updated_at", "vacant", "zoning"]
    end
end
