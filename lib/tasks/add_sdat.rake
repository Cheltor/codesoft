namespace :address do
  desc "Update addresses with district and property_id values from CSV"
  task update_district_and_property_id: :environment do
    require 'csv'

    csv_data = CSV.read("db/PL 22 CSV - Sheet1.csv", headers: true)

    csv_data.each do |row|
      address = Address.find_by(pid: row['PID'])
      if address
        address.update(district: row['DISTRICT'], property_id: row['PROPERTY_ID']) # new columns
      end
    end
  end
end