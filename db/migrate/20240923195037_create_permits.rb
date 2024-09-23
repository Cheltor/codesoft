class CreatePermits < ActiveRecord::Migration[7.0]
  def change
    create_table :permits do |t|
      t.integer :address_id
      t.integer :inspection_id
      t.boolean :sent
      t.boolean :revoked
      t.string :fiscal_year
      t.date :expiration_date
      t.string :permitnumber
      t.date :date_issued
      t.text :conditions
      t.boolean :paid

      t.timestamps
    end
  end
end
