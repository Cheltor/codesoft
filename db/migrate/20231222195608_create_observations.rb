class CreateObservations < ActiveRecord::Migration[7.0]
  def change
    create_table :observations do |t|
      t.text :content
      t.references :area, null: false, foreign_key: true
      t.string :photos
      t.boolean :potentialvio

      t.timestamps
    end
  end
end
