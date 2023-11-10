class CreateViolationComments < ActiveRecord::Migration[7.0]
  def change
    create_table :violation_comments do |t|
      t.references :violation, null: false, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
