class AddLicenseTypeToLicenses < ActiveRecord::Migration[7.0]
  def change
    add_column :licenses, :license_type, :integer
  end
end
