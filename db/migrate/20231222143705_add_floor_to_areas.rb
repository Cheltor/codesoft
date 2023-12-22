class AddFloorToAreas < ActiveRecord::Migration[7.0]
  def change
    add_column :areas, :floor, :integer
  end
end
