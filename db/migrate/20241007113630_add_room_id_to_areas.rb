class AddRoomIdToAreas < ActiveRecord::Migration[7.0]
  def change
    add_column :areas, :room_id, :integer
  end
end
