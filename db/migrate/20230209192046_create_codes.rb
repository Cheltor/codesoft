class CreateCodes < ActiveRecord::Migration[7.0]
  def change
    create_table :codes do |t|
      t.string :chapter
      t.string :section
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
