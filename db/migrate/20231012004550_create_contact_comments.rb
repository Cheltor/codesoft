class CreateContactComments < ActiveRecord::Migration[7.0]
  def change
    create_table :contact_comments do |t|
      t.text :comment
      t.references :user, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: true

      t.timestamps
    end
  end
end
