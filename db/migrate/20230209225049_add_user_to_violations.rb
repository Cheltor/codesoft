class AddUserToViolations < ActiveRecord::Migration[7.0]
  def change
    add_reference :violations, :user, null: false, foreign_key: true
  end
end
