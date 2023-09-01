class AddAssigneeToInspections < ActiveRecord::Migration[7.0]
  def change
    add_column :inspections, :assignee, :string
  end
end
