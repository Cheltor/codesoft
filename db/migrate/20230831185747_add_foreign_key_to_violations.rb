class AddForeignKeyToViolations < ActiveRecord::Migration[7.0]
  def change
    add_reference :violations, :inspection, foreign_key: true
  end
end
