class CreateInspectionComments < ActiveRecord::Migration[7.0]
  def change
    create_table :inspection_comments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :inspection, null: false, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
