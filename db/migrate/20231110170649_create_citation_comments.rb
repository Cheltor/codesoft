class CreateCitationComments < ActiveRecord::Migration[7.0]
  def change
    create_table :citation_comments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :citation, null: false, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
