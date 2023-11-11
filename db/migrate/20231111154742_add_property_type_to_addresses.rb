class AddPropertyTypeToAddresses < ActiveRecord::Migration[7.0]
  def change
    add_column :addresses, :property_type, :string
  end
end
