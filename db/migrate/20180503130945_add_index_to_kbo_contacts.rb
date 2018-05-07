class AddIndexToKboContacts < ActiveRecord::Migration[5.1]
  def change
    add_index :kbo_contacts, [:entity_number, :contact_type]
  end
end
