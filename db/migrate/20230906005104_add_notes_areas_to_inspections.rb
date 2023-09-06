class AddNotesAreasToInspections < ActiveRecord::Migration[7.0]
  def change
    add_column :inspections, :notes_area_1, :text
    add_column :inspections, :notes_area_2, :text
    add_column :inspections, :notes_area_3, :text
  end
end
