class AddStatusAndTrialDateToCitations < ActiveRecord::Migration[7.0]
  def change
    add_column :citations, :status, :integer
    add_column :citations, :trial_date, :date
  end
end
