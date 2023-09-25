class AddNewContactInfoToInspections < ActiveRecord::Migration[7.0]
  def change
    add_column :inspections, :new_contact_name, :string
    add_column :inspections, :new_contact_email, :string
    add_column :inspections, :new_contact_phone, :string
  end
end
