class AddDistrictAndPropertyIdToAddresses < ActiveRecord::Migration[7.0]
  def change
    add_column :addresses, :district, :string
    add_column :addresses, :property_id, :string
  end
end
