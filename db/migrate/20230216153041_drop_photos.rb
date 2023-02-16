class DropPhotos < ActiveRecord::Migration[6.1]
  def up
    drop_table :photos
  end

  def down
    create_table :photos do |t|
      t.string :image
      t.timestamps
    end
  end
end
