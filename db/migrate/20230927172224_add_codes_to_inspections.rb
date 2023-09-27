class AddCodesToInspections < ActiveRecord::Migration[7.0]
  def change
    add_column :inspections, :new_chapter, :string
    add_column :inspections, :new_section, :string
    add_column :inspections, :new_name, :string
    add_column :inspections, :new_description, :string
  end
end
