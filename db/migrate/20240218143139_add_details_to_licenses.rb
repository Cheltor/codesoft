class AddDetailsToLicenses < ActiveRecord::Migration[7.0]
  def change
    add_column :licenses, :sent, :boolean
    add_column :licenses, :revoked, :boolean
    add_column :licenses, :fiscal_year, :string
    add_column :licenses, :expiration_date, :date
  end
end
