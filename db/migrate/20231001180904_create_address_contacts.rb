class CreateAddressContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :address_contacts do |t|
      t.references :address, null: true, foreign_key: true
      t.references :contact, null: true, foreign_key: true

      t.timestamps
    end
  end
end
