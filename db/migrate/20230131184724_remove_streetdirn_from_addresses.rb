class RemoveStreetdirnFromAddresses < ActiveRecord::Migration[7.0]
  def change
    remove_column :addresses, :streetdirn, :string
  end
end
