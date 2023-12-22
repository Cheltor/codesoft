class AddStartTimeToInspections < ActiveRecord::Migration[7.0]
  def change
    add_column :inspections, :start_time, :datetime
  end
end
