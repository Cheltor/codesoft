class CreateAreas < ActiveRecord::Migration[7.0]
  def change
    create_table :areas do |t|
      t.string :name
      t.text :notes
      t.string :photos

      t.timestamps
    end
  end
end
