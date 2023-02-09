class CreateViolations < ActiveRecord::Migration[7.0]
  def change
    create_table :violations do |t|
      t.string :description
      t.integer :status
      t.references :address, null: false, foreign_key: true

      t.timestamps
    end
  end
end
