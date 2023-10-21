class BusinessContact < ApplicationRecord
  belongs_to :business
  belongs_to :contact
end
