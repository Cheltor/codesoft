class AddViolationTypeToViolations < ActiveRecord::Migration[7.0]
  def change
    add_column :violations, :violation_type, :string
  end
end
