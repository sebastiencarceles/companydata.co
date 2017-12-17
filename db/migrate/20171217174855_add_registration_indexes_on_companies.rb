class AddRegistrationIndexesOnCompanies < ActiveRecord::Migration[5.1]
  def change
    add_index :companies, [:registration_1, :registration_2]
  end
end
