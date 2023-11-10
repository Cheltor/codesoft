class AddUserToViolationComments < ActiveRecord::Migration[7.0]
  def change
    add_reference :violation_comments, :user, null: false, foreign_key: true
  end
end
