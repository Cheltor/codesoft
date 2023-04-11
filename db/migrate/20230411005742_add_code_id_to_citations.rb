class AddCodeIdToCitations < ActiveRecord::Migration[7.0]
  def change
    add_reference :citations, :code, null: false, foreign_key: true
  end
end
