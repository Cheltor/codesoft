class AddInspectionReferenceToAreas < ActiveRecord::Migration[7.0]
  def change
    add_reference :areas, :inspection, null: false, foreign_key: true
  end
end
