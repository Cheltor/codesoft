class AddBusinessRefToInspections < ActiveRecord::Migration[7.0]
  def change
    add_reference :inspections, :business, null: true, foreign_key: true
  end
end
