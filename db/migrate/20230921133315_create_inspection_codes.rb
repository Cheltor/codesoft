class CreateInspectionCodes < ActiveRecord::Migration[7.0]
  def change
    create_table :inspection_codes do |t|
      t.references :inspection, null: false, foreign_key: true
      t.references :code, null: false, foreign_key: true

      t.timestamps
    end
  end
end
