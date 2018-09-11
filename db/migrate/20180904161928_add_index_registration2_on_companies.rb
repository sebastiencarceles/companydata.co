class AddIndexRegistration2OnCompanies < ActiveRecord::Migration[5.1]
  def change
    add_index :companies, :registration_2
  end
end
