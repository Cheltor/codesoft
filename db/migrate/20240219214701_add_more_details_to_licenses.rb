class AddMoreDetailsToLicenses < ActiveRecord::Migration[7.0]
  def change
    add_column :licenses, :license_number, :string
    add_column :licenses, :date_issued, :date
    add_column :licenses, :conditions, :text
  end
end
