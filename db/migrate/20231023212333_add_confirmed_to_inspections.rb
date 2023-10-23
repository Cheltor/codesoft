class AddConfirmedToInspections < ActiveRecord::Migration[7.0]
  def change
    add_column :inspections, :confirmed, :boolean, default: false
  end
end
