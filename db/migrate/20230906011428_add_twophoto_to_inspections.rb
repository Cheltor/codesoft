class AddTwophotoToInspections < ActiveRecord::Migration[7.0]
  def change
    add_column :inspections, :intphotos, :string
    add_column :inspections, :extphotos, :string
  end
end
