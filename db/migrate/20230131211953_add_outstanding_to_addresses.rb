class AddOutstandingToAddresses < ActiveRecord::Migration[7.0]
  def change
    add_column :addresses, :outstanding, :boolean
  end
end
