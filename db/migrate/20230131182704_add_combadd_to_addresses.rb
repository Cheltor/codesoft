class AddCombaddToAddresses < ActiveRecord::Migration[7.0]
  def change
    add_column :addresses, :combadd, :string
  end
end
