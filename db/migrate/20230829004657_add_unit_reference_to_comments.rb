class AddUnitReferenceToComments < ActiveRecord::Migration[7.0]
  def change
    add_reference :comments, :unit, null: true, foreign_key: true
  end
end
