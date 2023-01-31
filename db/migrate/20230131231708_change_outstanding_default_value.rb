class ChangeOutstandingDefaultValue < ActiveRecord::Migration[7.0]
  def change
    change_column_default :addresses, :outstanding, false
  end
end
