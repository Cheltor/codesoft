class AddAttributesToBusiness < ActiveRecord::Migration[7.0]
  def change
    add_column :businesses, :website, :string
    add_column :businesses, :email, :string
    add_column :businesses, :phone, :string
  end
end
