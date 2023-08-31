class CreateInspections < ActiveRecord::Migration[7.0]
  def change
    create_table :inspections do |t|
      t.string :source
      t.string :status
      t.string :attachments
      t.string :result
      t.text :description
      t.text :thoughts
      t.string :originator
      t.references :unit, null: true, foreign_key: true
      t.references :address, null: false, foreign_key: true

      t.timestamps
    end
  end
end
