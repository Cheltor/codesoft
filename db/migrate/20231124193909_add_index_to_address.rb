class AddIndexToAddress < ActiveRecord::Migration[7.0]
  def change
    add_index :addresses, :combadd
    add_index :addresses, :property_name
  end
end
