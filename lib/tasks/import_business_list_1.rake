# lib/tasks/import_businesses.rake

require 'roo'

namespace :importList1 do
  desc "Import businesses from Excel file"
  task businesses: :environment do
    file_path = Rails.root.join('lib', 'data', 'Business_List_1.xlsx')
    xlsx = Roo::Spreadsheet.open(file_path.to_s)

    xlsx.each_with_index do |row, index|
      next if index == 0 # Skip header row

      business_name = row[0]
      address = row[2].to_s.strip.upcase # Normalize address
      email = row[6] # G
      phone = row[7] # H
      # Add other columns as needed

      # Find address with matching combadd
      address_record = Address.find_by('UPPER(combadd) = ?', address)
      
      if address_record
        puts "Found matching address for #{business_name}: #{address}"
        # Create a new business entry
          Business.create(
            name: business_name,
            address: address_record,
            email: email,
            phone: phone
          )
      else
        puts "No match found for #{business_name}: #{address}"
        # Create a new business entry or handle accordingly
        # Business.create(name: business_name, address: address_record, ...)
      end
    end
  end
end
