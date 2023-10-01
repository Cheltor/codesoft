# app/models/address_contact.rb
class AddressContact < ApplicationRecord
  belongs_to :address
  belongs_to :contact
end
