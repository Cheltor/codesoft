class RemovePhotoFromComments < ActiveRecord::Migration[7.0]
  def change
    remove_column :comments, :photo, :string
  end
end
