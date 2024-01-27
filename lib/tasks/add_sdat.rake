namespace :address do
  desc "Update addresses with sdat values from CSV"
  task update_sdat: :environment do
    require 'csv'

    csv_data = CSV.read('path_to_your_csv_file.csv', headers: true)

    csv_data.each do |row|
      address = Address.find_by(pid: row['PID'])
      if address
        address.update(sdat: row['SDAT']) # new column
      end
    end
  end
end