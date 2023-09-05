class AddInspectorToInspections < ActiveRecord::Migration[7.0]
  def change
    add_reference :inspections, :inspector, null: true, foreign_key: { to_table: :users }
  end
end
