class AddPropertyNameToAddresses < ActiveRecord::Migration[7.0]
  def change
    add_column :addresses, :property_name, :string
  end
end
