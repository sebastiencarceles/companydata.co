class CreateKboContacts < ActiveRecord::Migration[5.1]
  def change
    create_table :kbo_contacts do |t|
      t.string :entity_number
      t.string :entity_contact
      t.string :contact_type
      t.string :value

      t.timestamps
    end
  end
end
