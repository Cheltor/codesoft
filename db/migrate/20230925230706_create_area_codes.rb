class CreateAreaCodes < ActiveRecord::Migration[7.0]
  def change
    create_table :area_codes do |t|
      t.references :area, null: false, foreign_key: true
      t.references :code, null: false, foreign_key: true

      t.timestamps
    end
  end
end
