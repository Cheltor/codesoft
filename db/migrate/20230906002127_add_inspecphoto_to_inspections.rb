class AddInspecphotoToInspections < ActiveRecord::Migration[7.0]
  def change
    add_column :inspections, :photos, :string
  end
end
