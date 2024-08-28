class AddUnitToAreas < ActiveRecord::Migration[7.0]
  def change
    add_reference :areas, :unit, null: true, foreign_key: true
  end
end
