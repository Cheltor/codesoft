class AddScheduledDateTimeToInspections < ActiveRecord::Migration[7.0]
  def change
    add_column :inspections, :scheduled_datetime, :datetime
  end
end
