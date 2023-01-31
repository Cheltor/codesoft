class CreateAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :addresses do |t|
      t.string :pid
      t.string :ownername
      t.string :owneraddress
      t.string :ownercity
      t.string :ownerstate
      t.string :ownerzip
      t.string :streetnumb
      t.string :streetdirn
      t.string :streetname
      t.string :streettype
      t.string :landusecode
      t.string :zoning
      t.string :owneroccupiedin
      t.string :vacant
      t.string :absent
      t.string :premisezip

      t.timestamps
    end
  end
end
