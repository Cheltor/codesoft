class AddVacancyStatusToUnits < ActiveRecord::Migration[7.0]
  def change
    add_column :units, :vacancy_status, :string
  end
end
