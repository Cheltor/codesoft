class AddAkaToAddresses < ActiveRecord::Migration[7.0]
  def change
    add_column :addresses, :aka, :string
  end
end
