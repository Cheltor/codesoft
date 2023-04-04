class CreateCitations < ActiveRecord::Migration[7.0]
  def change
    create_table :citations do |t|
      t.integer :fine
      t.date :deadline
      t.references :violation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
