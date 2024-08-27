class AddPaidToInspections < ActiveRecord::Migration[7.0]
  def change
    add_column :inspections, :paid, :boolean, default: false, null: false
  end
end
