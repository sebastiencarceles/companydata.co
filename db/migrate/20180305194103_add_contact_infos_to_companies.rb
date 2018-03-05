class AddContactInfosToCompanies < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :civility, :string
    add_column :companies, :first_name, :string
    add_column :companies, :last_name, :string
    add_column :companies, :email, :string
    add_column :companies, :phone, :string
  end
end
