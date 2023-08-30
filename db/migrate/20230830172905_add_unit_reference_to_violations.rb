class AddUnitReferenceToViolations < ActiveRecord::Migration[7.0]
  def change
    add_reference :violations, :unit, null: true, foreign_key: true
  end
end
