# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
require 'csv'

# Load data from the CSV file into a Ruby array of hashes
csv_data = CSV.read("db/PL 22 CSV - Sheet1.csv", headers: true)

# Loop through the array of hashes and create records in the database
csv_data.each do |row|
    Address.create!(
        pid: row['PID'],
        ownername: row['OWNERNAME'],
        owneraddress: row['OWNERADDRESS'],
        ownercity: row['OWNERCITY'],
        ownerstate: row['OWNERSTATE'],
        ownerzip: row['OWNERZIP'],
        streetnumb: row['STREETNUMB'],
        streetdirn: row['STREETDIRN'],
        streetname: row['STREETNAME'],
        streettype: row['STREETTYPE'],
        landusecode: row['LANDUSECODE'],
        zoning: row['ZONING'],
        owneroccupiedin: row['OWNEROCCUPIEDIN'],
        vacant: row['VACANT'],
        absent: row['ABSENT'],
        premisezip: row['PREMISEZIP']
    )
end