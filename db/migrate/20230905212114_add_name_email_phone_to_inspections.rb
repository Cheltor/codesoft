class AddNameEmailPhoneToInspections < ActiveRecord::Migration[7.0]
  def change
    add_column :inspections, :name, :string
    add_column :inspections, :email, :string
    add_column :inspections, :phone, :string
  end
end
