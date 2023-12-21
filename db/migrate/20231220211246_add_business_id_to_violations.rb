class AddBusinessIdToViolations < ActiveRecord::Migration[7.0]
  def change
    add_column :violations, :business_id, :integer
  end
end
