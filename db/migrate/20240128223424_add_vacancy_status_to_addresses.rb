class AddVacancyStatusToAddresses < ActiveRecord::Migration[7.0]
  def change
    add_column :addresses, :vacancy_status, :string
  end
end
