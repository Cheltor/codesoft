class AddUnitToBusinesses < ActiveRecord::Migration[7.0]
  def change
    add_reference :businesses, :unit, null: true, foreign_key: true
  end
end
