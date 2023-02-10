class AddDeadlineToViolations < ActiveRecord::Migration[7.0]
  def change
    add_column :violations, :deadline, :string
  end
end
