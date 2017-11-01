class AddCountryToCompanies < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :country, :string
  end
end
