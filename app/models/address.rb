class Address < ApplicationRecord
    has_many :comments
    has_many :users, through: :comments
    has_many :violations
    
    def toggle_outstanding_violation
        self.update_attribute(:outstanding_violation, !self.outstanding_violation)
    end      
end
