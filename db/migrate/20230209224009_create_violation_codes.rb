class CreateViolationCodes < ActiveRecord::Migration[7.0]
  def change
    create_table :violation_codes do |t|
      t.belongs_to :violation, null: false, foreign_key: true
      t.belongs_to :code, null: false, foreign_key: true

      t.timestamps
    end
  end
end
