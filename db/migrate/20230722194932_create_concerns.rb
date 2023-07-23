class CreateConcerns < ActiveRecord::Migration[7.0]
  def change
    create_table :concerns do |t|
      t.references :address, null: false, foreign_key: true
      t.text :content
      t.string :emailorphone

      t.timestamps
    end
  end
end
