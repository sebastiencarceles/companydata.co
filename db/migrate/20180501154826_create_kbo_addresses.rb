class CreateKboAddresses < ActiveRecord::Migration[5.1]
  def change
    create_table :kbo_addresses do |t|
      t.string :entity_number
      t.string :type_of_address
      t.string :country
      t.string :zipcode
      t.string :municipality
      t.string :street
      t.string :house_number
      t.string :box
      t.string :extra_address_info
      t.string :date_striking_off

      t.timestamps
    end
  end
end
