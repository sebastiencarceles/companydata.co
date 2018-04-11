class AddCountryCodeToCompanies < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :country_code, :string, length: 2
  end
end
