class AddPhotoToComments < ActiveRecord::Migration[7.0]
  def change
    add_column :comments, :photo, :string
  end
end
