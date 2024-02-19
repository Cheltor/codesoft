class AddBusinessRefToLicenses < ActiveRecord::Migration[7.0]
  def change
    add_reference :licenses, :business, foreign_key: true
  end
end
