class AddPaidToLicenses < ActiveRecord::Migration[7.0]
  def change
    add_column :licenses, :paid, :boolean, default: false, null: false
  end
end
