class AddNotesToContacts < ActiveRecord::Migration[7.0]
  def change
    add_column :contacts, :notes, :text, default: ""
  end
end
