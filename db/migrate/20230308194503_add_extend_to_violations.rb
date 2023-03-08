class AddExtendToViolations < ActiveRecord::Migration[7.0]
  def change
    add_column :violations, :extend, :integer, default: 0
  end
end
