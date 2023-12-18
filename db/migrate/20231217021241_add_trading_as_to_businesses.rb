class AddTradingAsToBusinesses < ActiveRecord::Migration[7.0]
  def change
    add_column :businesses, :trading_as, :string
  end
end
